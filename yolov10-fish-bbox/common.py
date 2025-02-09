import cv2

class YOLOResult:
    def __init__(self, box, image):
        """
        Initializes the YOLOResult.
        
        Args:
            box (list): List containing bounding box coordinates and confidence score.
            image (numpy.ndarray): Image from which the mask will be cropped.
        """
        self.box = box[:4].astype(int)
        self.score = box[4]
        self.x1, self.y1, self.x2, self.y2 = map(int, self.box)
        
        self.width = self.x2 - self.x1
        self.height = self.y2 - self.y1
        
        self.mask = image[self.y1:self.y2, self.x1:self.x2]
        
        # Additional attributes for convenience
        self.center_x = self.x1 + self.width / 2
        self.center_y = self.y1 + self.height / 2
        
    def get_box(self):
        """
        Returns the bounding box coordinates.
        
        Returns:
            tuple: Bounding box coordinates (x1, y1, x2, y2).
        """
        return self.x1, self.y1, self.x2, self.y2
    
    def get_score(self):
        """
        Returns the confidence score.
        
        Returns:
            float: Confidence score.
        """
        return self.score
    
    def get_area(self):
        """
        Calculates the area of the bounding box.
        
        Returns:
            int: Area of the bounding box.
        """
        return self.width * self.height
    
    def draw_box(self, image, color=(0, 255, 0), thickness=2):
        """
        Draws the bounding box on the image.
        
        Args:
            image (numpy.ndarray): Image on which the box will be drawn.
            color (tuple): Color of the box in (B, G, R) format.
            thickness (int): Thickness of the box lines.
        """
        cv2.rectangle(image, (self.x1, self.y1), (self.x2, self.y2), color, thickness)
    
    def draw_label(self, image, label, color=(0, 255, 0), font_scale=0.5, thickness=1):
        """
        Draws a label next to the bounding box.
        
        Args:
            image (numpy.ndarray): Image on which the label will be drawn.
            label (str): Text of the label.
            color (tuple): Color of the text in (B, G, R) format.
            font_scale (float): Font scale of the text.
            thickness (int): Thickness of the text lines.
        """
        label_size, _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, font_scale, thickness)
        top_left = (self.x1, self.y1 - label_size[1])
        bottom_right = (self.x1 + label_size[0], self.y1)
        
        cv2.rectangle(image, top_left, bottom_right, color, cv2.FILLED)
        cv2.putText(image, label, (self.x1, self.y1), cv2.FONT_HERSHEY_SIMPLEX, font_scale, (0, 0, 0), thickness)

    def get_mask_BGR(self):
        """
        Returns the mask in BGR format.
        
        Returns:
            numpy.ndarray: Mask in BGR format.
        """
        return self.mask

    def get_mask_RGB(self):
        """
        Returns the mask in RGB format.
        
        Returns:
            numpy.ndarray: Mask in RGB format.
        """
        return cv2.cvtColor(self.mask, cv2.COLOR_BGR2RGB)

    def __repr__(self):
        return f"YOLOResult(box_xyxy=({self.x1}, {self.y1}, {self.x2}, {self.y2}), score={self.score})"

    def to_dict(self):
        """
        Converts the object to a dictionary.
        
        Returns:
            dict: Dictionary with keys 'box' and 'score'.
        """
        return {
            'box': [self.x1, self.y1, self.x2, self.y2],
            'score': self.score,
            'area': self.get_area(),
            'center': (self.center_x, self.center_y)
        }

class Letterbox:
    def __init__(self, target_size, color=(0, 0, 0)):
        self.target_size = target_size
        self.color = color

    def __call__(self, image):
        return self.letterbox(image)

    def letterbox(self, image):
        shape = image.shape[:2]  # current shape [height, width]
        new_shape = self.target_size

        # Scale ratio (new / old)
        ratio = min(new_shape[0] / shape[0], new_shape[1] / shape[1])
        new_unpad = int(round(shape[0] * ratio)), int(round(shape[1] * ratio))
        
        # Compute padding
        dh, dw = new_shape[0] - new_unpad[0], new_shape[1] - new_unpad[1]
        dw /= 2  # divide padding into 2 sides
        dh /= 2

        if shape[::-1] != new_unpad:  # resize
            image = cv2.resize(image, (new_unpad[1], new_unpad[0]), interpolation=cv2.INTER_LINEAR)

        top, bottom = int(round(dh - 0.1)), int(round(dh + 0.1))
        left, right = int(round(dw - 0.1)), int(round(dw + 0.1))
        
        image = cv2.copyMakeBorder(image, top, bottom, left, right, cv2.BORDER_CONSTANT, value=self.color)  # add border
        return image, [ratio, dh, dw]