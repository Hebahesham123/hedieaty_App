import 'package:flutter/material.dart';
import 'package:hediaty_appp/Views/Event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hediaty_appp/Views/AddFriendScreen.dart';
import 'package:hediaty_appp/Views/FriendsList.dart';
import 'package:hediaty_appp/Views/ProfilePage.dart';
import 'package:hediaty_appp/Views/myPledged.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    FriendListScreen(currentUserId: (FirebaseAuth.instance.currentUser?.uid)!),
    EventManagementScreen(userId: FirebaseAuth.instance.currentUser?.uid),
    ProfilePage(),
    PledgedGiftsPage(userId: (FirebaseAuth.instance.currentUser?.uid)!),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.grey, // Color for the selected icon
        unselectedItemColor: Colors.black, // Color for unselected icons
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Friends",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Event",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: "My pledged",
          ),
        ],
      ),
    );
  }
}
