import 'package:flutter/material.dart';
import 'package:hediaty_appp/Controllers/Friend_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediaty_appp/Views/AddFriendScreen.dart';
import 'package:hediaty_appp/Views/FriendEventsScreen.dart';

class FriendListScreen extends StatefulWidget {
  final String currentUserId;

  FriendListScreen({required this.currentUserId});

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final FriendController _controller = FriendController();
  List<Map<String, String>> _friends = []; // To hold friends data

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    await _controller.syncFriends(widget.currentUserId);
    final friendIds = await _controller.fetchFriends(widget.currentUserId);


    List<Map<String, String>> friendsData = [];
    for (final friendId in friendIds) {
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();

      if (friendDoc.exists) {
        final friendData = friendDoc.data();
        friendsData.add({
          'uid': friendId, // Add UID to navigate later
          'name': friendData?['name'] ?? 'Unknown',
          'phone': friendData?['mobile'] ?? 'N/A',
        });
      }
    }

    setState(() {
      _friends = friendsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friends List"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadFriends,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(friend['name']!),
                    subtitle: Text("Phone: ${friend['phone']}"),
                    onTap: () {
                      // Navigate to FriendEventsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendEventsScreen(
                            friendId: friend['uid']!,
                            friendName: friend['name']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFriendScreen(
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  ).then((_) => _loadFriends()); // Refresh the list on return
                },
                icon: Icon(Icons.person_add),
                label: Text("Add Friend"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
