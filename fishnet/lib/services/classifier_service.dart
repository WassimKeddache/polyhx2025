import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
    late Interpreter _interpreter;

    static const String modelFile = 'lib/assets/model.tflite';

    Future<void> loadModel() async {
        try {
            _interpreter = await Interpreter.fromAsset(modelFile);
            print(_interpreter.getInputTensor(0).shape);
        } catch (e) {
            print("Erreur lors du chargement du modèle : $e");
        }
    }

    Interpreter get interpreter => _interpreter;
}