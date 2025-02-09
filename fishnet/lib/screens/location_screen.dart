import 'package:flutter/material.dart';
import '../widget/bottom_nav_bar.dart'; 

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Define a list of fish with their catchable status and image URL
  final List<Map<String, dynamic>> fishList = [
    {'name': 'Salmon', 'image': 'lib/assets/salmon.jpg'},
    {'name': 'Trout', 'image': 'lib/assets/trout.jpg'},
    {'name': 'Catfish',  'image': 'lib/assets/catfish.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    // Filter fish that are not catchable
    final nonCatchableFish = fishList;

    return Scaffold(
      appBar: AppBar(
        title: Text('Location Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fish that are not catchable:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // List the non-catchable fish as Cards
            Expanded(
              child: ListView.builder(
                itemCount: nonCatchableFish.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Image.asset(
                        nonCatchableFish[index]['image'], 
                        width: 50, 
                        height: 50, 
                        fit: BoxFit.cover,
                      ),
                      title: Text(nonCatchableFish[index]['name']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
      ),
    );
  }
}
