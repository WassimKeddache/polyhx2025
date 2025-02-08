import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Assurez-vous d'importer le HomeScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Définir le HomeScreen comme page d'accueil
    );
  }
}