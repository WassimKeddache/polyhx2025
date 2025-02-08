import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widget/bottom_nav_bar.dart';

class IdentificationScreen extends StatefulWidget {
  @override
  _IdentificationScreenState createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile;

  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();

    await Permission.camera.request();

    _initializeControllerFuture.then((_) {
      setState(() {
        _isCameraInitialized = true;
      });
    }).catchError((e) {
      print('Erreur lors de l\'initialisation de la caméra : $e');
    });
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),

                // if (_imageFile != null)
                //   Positioned.fill(
                //     child: Center(
                //       child: Image.file(File(_imageFile!.path)),  // Affiche l'image capturée
                //     ),
                //   ),

                Positioned(
                  bottom: 30,
                  left: MediaQuery.of(context).size.width * 0.5 - 35,
                  child: FloatingActionButton(
                    onPressed: _takePicture,
                    child: Icon(Icons.camera_alt),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
      ),
    );
  }
}
