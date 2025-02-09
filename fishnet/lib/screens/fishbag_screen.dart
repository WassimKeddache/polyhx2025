import 'package:flutter/material.dart';
import '../widget/bottom_nav_bar.dart'; 

class FishBagScreen extends StatefulWidget {
  @override
  _FishBagScreenState createState() => _FishBagScreenState();
}

class _FishBagScreenState extends State<FishBagScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FishBag Screen'),
      ),
      body: Center(
        child: Text(
          'FishBagScreen',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
      ),
    );
  }
}
