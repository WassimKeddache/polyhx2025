import 'package:flutter/material.dart';
import 'identification_screen.dart';
import 'fishbag_screen.dart';
import 'glossary_screen.dart';
import 'location_screen.dart';
import '../widget/bottom_nav_bar.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text(
          'Bienvenue sur la page d\'accueil',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
      ),
    );
  }
}
