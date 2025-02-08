import 'package:flutter/material.dart';
import '../widget/bottom_nav_bar.dart'; 

class GlossaryScreen extends StatefulWidget {
  @override
  _GlossaryScreenState createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _glossaryText = "Glossary Screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Glossary Screen'),
      ),
      body: Center(
        child: Text(
          _glossaryText,
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 4,
      ),
    );
  }
}
