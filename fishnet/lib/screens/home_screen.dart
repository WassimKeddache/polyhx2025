import 'package:flutter/material.dart';
import 'fishbag_screen.dart';
import 'glossary_screen.dart';
import 'identification_screen.dart';
import 'location_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Liste des écrans à afficher
  static List<Widget> _screens = [
    HomePage(),          // HomeScreen comme premier écran
    IdentificationScreen(),
    FishBagScreen(),
    LocationScreen(),
    GlossaryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],  // Affiche l'écran en fonction de l'index sélectionné
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),  // Espacement autour des boutons
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Espacement égal entre les boutons
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () => _onItemTapped(0),  // Navigue vers Home
            ),
            IconButton(
              icon: Icon(Icons.screen_lock_portrait),
              onPressed: () => _onItemTapped(1),  // Navigue vers IdentificationScreen
            ),
            IconButton(
              icon: Icon(Icons.star),
              onPressed: () => _onItemTapped(2),  // Navigue vers FishBagScreen
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => _onItemTapped(3),  // Navigue vers LocationScreen
            ),
            IconButton(
              icon: Icon(Icons.account_box),
              onPressed: () => _onItemTapped(4),  // Navigue vers GlossaryScreen
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'accueil'),
      ),
      body: Center(
        child: Text(
          'Bienvenue sur la page d\'accueil',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
