onnx-tf convert -i ../ResNet18-v6-289-classes/models/model.onnx -o resnet_tf
python main.py --input resnet_tf --output resnet.tflite

