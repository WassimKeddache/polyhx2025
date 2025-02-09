import cv2
import torch
import numpy as np
from torchvision.transforms import functional as F
        
from common import YOLOResult, Letterbox

class YOLOInference():
    def __init__(self, model_path, imsz = (640, 640), conf_threshold = 0.05, nms_threshold = 0.3, yolo_ver = 'v10'):
        """
        Initializing a class with loading a model from TorchScript.
        Args:
        imsz: Size of input image to YOLO required
        conf_thresh: Confidence threshold to filter out low-confidence boxes.
        iou_thresh: IoU threshold for Non-Maximum Suppression.

        """

        self.model_path = model_path
        self.yolo_ver = yolo_ver

        self.fp_16 = False
        self.imsz = imsz
        self.conf_threshold = conf_threshold
        self.nms_threshold = nms_threshold
        self.letterbox = Letterbox(self.imsz)
    
    def v10postprocess(self, predictions):
        print(type(predictions))
        boxes, scores, labels = predictions.split([4, 1, 1], dim=-1)

        selected_boxes = []
        selected_scores = []
        for box_id in range(len(boxes)):
            if scores[box_id] > self.conf_threshold:
                new_box = [
                    max(0, boxes[box_id][0].item()), 
                    max(0, boxes[box_id][1].item()), 
                    min(self.imsz[0], boxes[box_id][2].item()), 
                    min(self.imsz[0], boxes[box_id][3].item())]
                
                selected_boxes.append(new_box)
                selected_scores.append(scores[box_id].item())
                
        if len(selected_boxes) != 0:
            
            selected_boxes = np.array(selected_boxes)
            selected_scores = np.array(selected_scores).reshape(-1, 1)
            boxes_scores = np.hstack([selected_boxes, selected_scores])

            indices = self.nms(boxes_scores)
            selected_boxes = boxes_scores[indices]

        return selected_boxes

    
    def v8postprocess(self, predictions):
        """
        Post-processing for the YOLO V8 object detection model.

        Arguments:
        predictions (np.array): Prediction tensor of size (1, 5, 8400).

        Returns:
        np.array:Array of filtered boxes after NMS.
        """
        # Extracting Predictions from a Tensor
        x_center, y_center, width, height, confidence = predictions

        # Convert coordinates from center to angular
        x1 = x_center - width / 2
        y1 = y_center - height / 2
        x2 = x_center + width / 2
        y2 = y_center + height / 2

        boxes = np.stack((x1, y1, x2, y2, confidence), axis=1)

        # Filtering boxes by confidence threshold
        boxes = boxes[boxes[:, 4] > self.conf_threshold]

        # Application of non-maximum suppression
        indices = self.nms(boxes)
        boxes = boxes[indices]

        return boxes

    def nms(self, boxes):
        """
        Non-Maximum Suppression (NMS) to remove overlapping boxes.

        Arguments:
        boxes (np.array): An array of boxes of size (N, 5), where N is the number of boxes.

        Returns:
        list: List of indexes of selected boxes.
        """

        x1 = boxes[:, 0]
        y1 = boxes[:, 1]
        x2 = boxes[:, 2]
        y2 = boxes[:, 3]
        scores = boxes[:, 4]

        areas = (x2 - x1 + 1) * (y2 - y1 + 1)
        order = scores.argsort()[::-1]

        keep = []
        while order.size > 0:
            i = order[0]
            keep.append(i)

            xx1 = np.maximum(x1[i], x1[order[1:]])
            yy1 = np.maximum(y1[i], y1[order[1:]])
            xx2 = np.minimum(x2[i], x2[order[1:]])
            yy2 = np.minimum(y2[i], y2[order[1:]])

            w = np.maximum(0, xx2 - xx1 + 1)
            h = np.maximum(0, yy2 - yy1 + 1)

            inter = w * h
            overlap = inter / (areas[i] + areas[order[1:]] - inter)

            order = order[np.where(overlap <= self.nms_threshold)[0] + 1]

        return keep

    def scale_coords_back(self, img_shape, coords, params):
        # Rescale coords (xyxy) from target image shape to original image shape
        ratio, dh, dw = params
        gain = ratio
        
        coords[:, [0, 2]] -= dw  # x padding
        coords[:, [1, 3]] -= dh  # y padding
        
        coords[:, :4] /= gain
        
        coords = np.clip(coords, 0, [np.max(img_shape), np.max(img_shape), img_shape[1], img_shape[0], 1])
       
        condition = (coords[:, 2] - coords[:, 0] > 10) & (coords[:, 3] - coords[:, 1] > 10)
        coords = coords[condition]

        return coords
    
    def predict(self, im_bgr):
        
        # Checking the type of the input argument and casting to a list
        if isinstance(im_bgr, np.ndarray):
            im_bgr = [im_bgr]
        
        input_imgs, params = self.preprocess(im_bgr)

        with torch.no_grad():
            predictions = self.model(input_imgs)
        
        final_pred = []
        for bbox_id in range(len(predictions)):
            if self.yolo_ver == 'v8':
                filtered_boxes = self.v8postprocess(predictions[bbox_id])
            elif self.yolo_ver == 'v10':
                filtered_boxes = self.v10postprocess(predictions[bbox_id])
                
            if len(filtered_boxes) == 0:
                final_pred.append([])
            else:
                boxes = self.scale_coords_back(im_bgr[bbox_id].shape[:2], filtered_boxes, params[bbox_id])
                final_pred.append([YOLOResult(box, im_bgr[bbox_id]) for box in boxes])
        return final_pred
    
class YOLOInferenceTorch(YOLOInference):
    def __init__(self, model_path, imsz=(640, 640), conf_threshold=0.05, nms_threshold=0.3, yolo_ver='v10'):
        super().__init__(model_path, imsz, conf_threshold, nms_threshold, yolo_ver)
        self.device = torch.device("cpu")
        self.model = torch.jit.load(model_path).to(self.device)
        self.model.eval()

    def preprocess(self, im):
        """
        Prepares input image before inference.

        Args:
            im (List(np.ndarray)): [(HWC) x B] for list.
        """

        im, params  = zip(*(self.letterbox(img) for img in im))
        
        im = np.stack(im)
        im = im[..., ::-1].transpose((0, 3, 1, 2))  # BGR to RGB, BHWC to BCHW, (n, 3, h, w)
        im = np.ascontiguousarray(im)  # contiguous
        im = torch.from_numpy(im)

        im = im.to('cpu')
        im = im.half() if self.fp_16 else im.float()  # uint8 to fp16/32

        im /= 255  # 0 - 255 to 0.0 - 1.0
        return im, params