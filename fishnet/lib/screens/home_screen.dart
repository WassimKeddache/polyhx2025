import 'package:flutter/material.dart';
import 'identification_screen.dart';
import 'fishbag_screen.dart';
import 'glossary_screen.dart';
import 'location_screen.dart';
import '../widget/bottom_nav_bar.dart';
import '../services/fetch_service.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  
  Widget build(BuildContext context) {
    FetchService fetchService = FetchService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            fetchService.fetch();
          },
          child: Text("fetch"),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
      ),
    );
  }
}
