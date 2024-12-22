import 'package:flutter/material.dart';
import 'package:hediaty_appp/Controllers/Friend_controller.dart';

class AddFriendScreen extends StatefulWidget {
  final String currentUserId;

  AddFriendScreen({required this.currentUserId});

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final FriendController _controller = FriendController();
  final TextEditingController _phoneController = TextEditingController();
  Map<String, dynamic>? _searchedUser; // To hold the searched user's data
  String _statusMessage = ''; // To show error/success messages

  Future<void> _searchUser() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _statusMessage = "Phone number is required.";
        _searchedUser = null;
      });
      return;
    }

    try {
      final user = await _controller.searchFriendByPhone(phone);

      if (user == null) {
        setState(() {
          _statusMessage = "No user found with this phone number.";
          _searchedUser = null;
        });
      } else {
        setState(() {
          _searchedUser = user;
          _statusMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error searching user: $e";
        _searchedUser = null;
      });
    }
  }

  Future<void> _addFriend() async {
    if (_searchedUser == null) return;

    try {
      await _controller.addFriend(widget.currentUserId, _searchedUser!['uid']);
      setState(() {
        _statusMessage = "Friend added successfully!";
        _searchedUser = null;
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error adding friend: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Friend"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Search by Phone Number",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchUser,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_searchedUser != null)
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(_searchedUser!['name']),
                  subtitle: Text("Phone: ${_searchedUser!['mobile']}"),
                  trailing: ElevatedButton(
                    onPressed: _addFriend,
                    child: Text("Add Friend"),
                  ),

                ),
              ),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
