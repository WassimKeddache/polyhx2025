import argparse
from typing import List 

import cv2
import tensorflow as tf
import numpy as np

from inference import YOLOInference, YOLOResult

MODEL_PATH="models/model.tflite"

class YOLOInferenceTFlite(YOLOInference):
    def __init__(self, model_path, imsz = (640, 640), conf_threshold = 0.05, nms_threshold = 0.3, yolo_ver = 'v10'):
        super().__init__(model_path, imsz, conf_threshold, nms_threshold, yolo_ver)
        self.interpreter = tf.lite.Interpreter(model_path=model_path)
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

        print(self.input_details)
        print(self.output_details)

        self.interpreter.allocate_tensors()

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
        im = im.astype(np.float32)
        im /= 255 

        return im, params
    
    def v10postprocess(self, predictions: np.ndarray):
        print(type(predictions))
        print(f"POST-PROCESSING SHAPE: {predictions.shape}")

        boxes  = predictions[:, :4]
        scores = predictions[:, 4]
        labels = predictions[:, 5]

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

    def predict(self, im_bgr):
        # Checking the type of the input argument and casting to a list
        if isinstance(im_bgr, np.ndarray):
            im_bgr = [im_bgr]
        
        input_imgs, params = self.preprocess(im_bgr)

        print(f"MODEL INPUT SHAPE: {input_imgs.shape}")
        self.interpreter.set_tensor(self.input_details[0]['index'], input_imgs)
        self.interpreter.invoke()

        predictions = self.interpreter.get_tensor(self.output_details[0]['index'])
        print(f"MODEL OUTPUT: {predictions.shape}")
        
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

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="An example of argparse.")
    parser.add_argument('--input', type=str, required=True, help="Input file path")

    args = parser.parse_args()
    
    model = YOLOInferenceTFlite(MODEL_PATH)

    im = cv2.imread(args.input)

    predictions: List[YOLOResult] = model.predict(im)

    current = predictions[0]
    for bbox in current:
        bbox.draw_box(im)

    cv2.imwrite("output-tflite.png", im)
