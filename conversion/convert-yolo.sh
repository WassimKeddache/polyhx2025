onnx-tf convert -i ../yolov10-fish-bbox/output/model.onnx -o yolo_tf
python main.py --input yolo_tf --output yolo.tflite