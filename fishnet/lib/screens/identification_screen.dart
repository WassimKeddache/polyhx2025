import 'dart:io'; // Pour manipuler les fichiers
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/classifier_service.dart'; // Importer le service de classification
import '../widget/bottom_nav_bar.dart'; // Importer le widget de la barre de navigation

class IdentificationScreen extends StatefulWidget {
  @override
  _IdentificationScreenState createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  late ClassifierService _classifierService; // Service de classification
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile; // Variable pour stocker l'image capturée

  bool _isCameraInitialized = false;
  bool _isPhotoTaken = false; // Pour savoir si une photo a été prise

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Initialiser la caméra au démarrage
    _classifierService =
        ClassifierService(); // Initialiser le service de classification
    _classifierService.loadModel(); // Charger le modèle de classification
  }

  // Initialiser la caméra
  void _initializeCamera() async {
    final cameras =
        await availableCameras(); // Récupérer les caméras disponibles
    final firstCamera = cameras.first; // Choisir la première caméra

    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();

    // Demander la permission pour la caméra
    await Permission.camera.request();

    // Attendre la fin de l'initialisation avant de changer l'état
    _initializeControllerFuture.then((_) {
      setState(() {
        _isCameraInitialized = true; // La caméra est prête
      });
    }).catchError((e) {
      print('Erreur lors de l\'initialisation de la caméra : $e');
    });
  }

  // Prendre une photo
  void _takePicture() async {
    try {
      await _initializeControllerFuture; // S'assurer que la caméra est prête avant de prendre la photo
      final image = await _controller.takePicture(); // Prendre une photo
      _classifierService.classifyImage(image); // Classer l'image capturée

      setState(() {
        _imageFile = image; // Sauvegarder l'image capturée dans une variable
        _isPhotoTaken = true; // Marquer qu'une photo a été prise
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  // Revenir à la vue de la caméra pour prendre une autre photo
  void _resetCamera() {
    setState(() {
      _isPhotoTaken = false; // Remettre à l'état initial, caméra visible
      _imageFile = null; // Réinitialiser l'image capturée
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Libérer la caméra lorsqu'on quitte la page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas de AppBar ici pour que la caméra prenne toute la page
      body: _isCameraInitialized
          ? Stack(
              children: [
                // Si une image a été prise, on l'affiche, sinon on montre la caméra
                if (_isPhotoTaken && _imageFile != null)
                  Positioned.fill(
                    child: Image.file(
                      File(_imageFile!.path), // Affiche l'image capturée
                      fit: BoxFit
                          .cover, // S'assurer que l'image occupe tout l'espace
                    ),
                  )
                else
                  Positioned.fill(
                    child: CameraPreview(_controller),
                  ),

                // Flèche pour revenir à la caméra pour prendre une autre photo
                if (_isPhotoTaken)
                  Positioned(
                    top: 20, // Positionner la flèche en haut à gauche
                    left: 10,
                    child: IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: _resetCamera, // Remet la caméra visible
                    ),
                  ),

                // Bouton de capture au centre en bas (seulement si la caméra est active)
                if (!_isPhotoTaken)
                  Positioned(
                    bottom:
                        90, // Positionné juste au-dessus de la barre de navigation
                    left: MediaQuery.of(context).size.width * 0.5 -
                        35, // Centrage horizontal
                    child: FloatingActionButton(
                      onPressed: _takePicture, // Prendre une photo
                      child:
                          Icon(Icons.camera_alt, size: 30), // Icône de capture
                      backgroundColor: Colors.white,
                      foregroundColor:
                          Colors.black, // Meilleur contraste sur un fond blanc
                      elevation:
                          10, // Ajoute une ombre pour un effet plus visible
                    ),
                  ),
              ],
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Afficher un indicateur de chargement pendant l'initialisation

      // La barre de navigation en bas sans espace
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1, // Indique que l'écran actif est "Identification"
      ),
    );
  }
}
