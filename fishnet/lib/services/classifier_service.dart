import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ClassifierService {
  late Interpreter _interpreter;
  late List<int> inputTensorShape;
  late int inputTensorSize;
  late List<List<int>> outputTensorShape;
  late List<int> outputTensorSizes;
  late Map<String, dynamic> labels;

  static const String modelFile = 'lib/assets/resnet-11.tflite';
  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std = [0.229, 0.224, 0.225];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelFile);
      inputTensorShape = _interpreter.getInputTensor(0).shape;
      inputTensorSize = inputTensorShape.reduce((a, b) => a * b);
      outputTensorShape = [];
      outputTensorSizes = [];
      _interpreter.getOutputTensors().forEach((outputTensor) {
        outputTensorShape.add(outputTensor.shape);
        outputTensorSizes.add(outputTensor.shape.reduce((a, b) => a * b));
      });
      _interpreter.allocateTensors();

      print(
          "INPUT SHAPE: $inputTensorShape, SIZE: $inputTensorSize, NUM OUTPUT TENSORS: ${outputTensorShape.length}");
      for (var outputShape in outputTensorShape) {
        print("OUTPUT SHAPE: $outputShape");
      }
      String jsonString = await rootBundle.loadString('lib/assets/labels.json');
      labels = await json.decode(jsonString);
    } catch (e) {
      print("Erreur lors du chargement du modèle : $e");
    }
  }

  Future<void> classifyImage(XFile xfile) async {
    try {
      // ByteData data = await rootBundle.load("lib/assets/test_image.png");
      // List<int> bytes = data.buffer.asUint8List();

      // Directory tempDir = await getTemporaryDirectory();
      // File file = File('${tempDir.path}/test_image.png');

      // await file.writeAsBytes(bytes);

      // xfile = XFile(file.path);
      Uint8List bytes2 = await xfile.readAsBytes();
      img.Image? image = img.decodeImage(Uint8List.fromList(bytes2));

      img.Image? resizedImage = img.copyResize(image!,
          width: inputTensorShape[inputTensorShape.length - 2],
          height: inputTensorShape[inputTensorShape.length - 1]);
      Float32List inputBytes = Float32List(inputTensorSize);

      int pixelIndex = 0;
      final sliceSize = inputTensorShape[inputTensorShape.length - 2] *
          inputTensorShape[inputTensorShape.length - 1];
      for (int y = 0; y < resizedImage.height; y++) {
        for (int x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y); // Récupère un objet Pixel
          inputBytes[pixelIndex] = ((pixel.b / 255.0) - mean[0]) / std[0];
          inputBytes[sliceSize + pixelIndex] =
              ((pixel.g / 255.0) - mean[1]) / std[1];
          inputBytes[2 * sliceSize + pixelIndex] =
              ((pixel.r / 255.0) - mean[2]) / std[2];

          pixelIndex++;
        }
      }

      final input = inputBytes.reshape(inputTensorShape);

      final output = {
        0: Float32List(outputTensorSizes[0]).reshape(outputTensorShape[0]),
        1: Float32List(outputTensorSizes[1]).reshape(outputTensorShape[1]),
      };

      _interpreter.runForMultipleInputs([input], output);

      print("FINISHED INFERENCE");
      final probabilities = output[1]![0];
      double max = 0;
      int maxIndex = 0;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > max) {
          max = probabilities[i];
          maxIndex = i;
        }
      }
      print("${maxIndex.toString()}, $max");
    } catch (e) {
      print("Erreur lors de la classification de l'image : $e");
      return;
    }
  }

  Interpreter get interpreter => _interpreter;
}
