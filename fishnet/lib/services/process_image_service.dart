import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class ProcessImageService {
  static Future<img.Image?> processImage(XFile xfile) async {
    try {
      // Uint8List bytes = await xfile.readAsBytes();
      // img.Image? image = img.decodeImage(bytes);
      // return image;
    } catch (e) {
      print("Erreur lors de la conversion : $e");
      return null;
    }
  }

  static img.Image applyGrayscale(img.Image image) {
    return img.grayscale(image);
  }

  static img.Image resizeImage(img.Image image, int width, int height) {
    return img.copyResize(image, width: width, height: height);
  }

  static Uint8List convertImageToBytes(img.Image image) {
    return Uint8List.fromList(img.encodeJpg(image));
  }
}
