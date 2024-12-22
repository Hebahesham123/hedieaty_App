import 'package:flutter/material.dart';
import 'package:hediaty_appp/Controllers/Event_controller.dart';
import 'package:hediaty_appp/Classes/Event.dart';
import 'package:hediaty_appp/Views/GiftListScreen.dart';

class FriendEventsScreen extends StatefulWidget {
  final String friendId;
  final String friendName;

  FriendEventsScreen({required this.friendId, required this.friendName});

  @override
  _FriendEventsScreenState createState() => _FriendEventsScreenState();
}

class _FriendEventsScreenState extends State<FriendEventsScreen> {
  final EventController _controller = EventController();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadFriendEvents();
  }

  Future<void> _loadFriendEvents() async {
    await _syncEvents();
    final events = await _controller.fetchEvents(widget.friendId);
    setState(() {
      _events = events;
    });
  }

  Future<void> _syncEvents() async {
    await _controller.syncEvents(widget.friendId);
    print("Events synchronized successfully!");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.friendName}'s Events"),
      ),
      body: _events.isEmpty
          ? Center(
        child: Text("No events found."),
      )
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(event.name),
              subtitle: Text("Date: ${event.date} | Location: ${event.location}"),
              onTap: () {
                // Navigate to GiftListScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftListScreen(
                      eventId: event.id,
                      eventName: event.name,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
