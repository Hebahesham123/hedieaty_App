import 'package:flutter/material.dart';
import 'package:hediaty_appp/Controllers/Event_controller.dart';
import 'package:hediaty_appp/Classes/Event.dart';
import 'package:hediaty_appp/Views/Gift.dart';
class EventManagementScreen extends StatefulWidget {
  final String? userId;

  EventManagementScreen({required this.userId});

  @override
  _EventManagementScreenState createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final EventController _controller = EventController();
  List<Event> _events = [];
  final _formKey = GlobalKey<FormState>();


  @override
  void initState()  {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await _syncEvents();
    final events = await _controller.fetchEvents(widget.userId!);
    setState(() {
      _events = events;
    });
  }

  Future<void> _syncEvents() async {
    await _controller.syncEvents(widget.userId!);
    print("Events synchronized successfully!");
  }

  Future<void> _deleteEvent(String eventId) async {
    await _controller.deleteEvent(eventId);
    _loadEvents();
  }

  Future<void> _togglePublished(String eventId, bool newStatus) async {
    final int statusAsInt = newStatus ? 1 : 0; // Convert bool to int (1 for true, 0 for false)
    print("SSSSSSSSSSSSSSSSSSSSS");
    print(statusAsInt);
    await _controller.togglePublishedStatus(eventId, statusAsInt);
    _loadEvents();
  }


  Future<void> _showEventDialog([Event? event]) async {
    final nameController = TextEditingController(text: event?.name ?? '');
    final dateController = TextEditingController(text: event?.date ?? '');
    final locationController =
    TextEditingController(text: event?.location ?? '');
    final descriptionController =
    TextEditingController(text: event?.description ?? '');
    final categoryController =
    TextEditingController(text: event?.category ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event == null ? "Create Event" : "Update Event"),
          content: SingleChildScrollView(
            child:Form(
          key: _formKey,
          child:
            Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date (yyyy-MM-dd)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required';
                    }
                    final parsedDate = DateTime.tryParse(value);
                    if (parsedDate == null) {
                      return 'Enter a valid date (yyyy-MM-dd)';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Location is required'
                      : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Description is required'
                      : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Category is required'
                      : null,
                ),
              ],
            ),
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
        if (_formKey.currentState!.validate()) {
            if (event == null) {
        await _controller.createEvent(
        name: nameController.text,
        date: dateController.text,
        location: locationController.text,
        userId: widget.userId!,
        description: descriptionController.text,
        category: categoryController.text,
        );
        } else {
        final updatedEvent = Event(
        id: event.id,
        name: nameController.text,
        date: dateController.text,
        location: locationController.text,
        description: descriptionController.text,
        category: categoryController.text,
        published: event.published,
        userId: event.userId,
        );
        await _controller.updateEvent(updatedEvent);
        }
        Navigator.pop(context);
        _loadEvents();
        };
        },

              child: Text(event == null ? "Create" : "Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Management"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showEventDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event.name),
            subtitle: Text("Date: ${event.date} | Published: ${event.published}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    event.published ? Icons.check_box : Icons.check_box_outline_blank,
                  ),
                  onPressed: () =>
                      _togglePublished(event.id, !event.published),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showEventDialog(event),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteEvent(event.id),
                ),
              ],
            ),
            onTap: () {
              // Navigate to GiftsPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftManagementScreen(eventId: event.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
