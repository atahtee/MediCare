import 'package:flutter/material.dart';
import 'package:medicare/Screens/HospitalScreen.dart';
import 'package:medicare/Screens/MapScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  dynamic _selectedHospital;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: IndexedStack(
          index: _currentIndex,
          children:  [
            HospitalScreen(),
            MapScreen(
              selectedHospital: _selectedHospital,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Hospitals',
            icon: Icon(Icons.local_hospital),
          ),
        ],
      ),
    );
  }
  

}
