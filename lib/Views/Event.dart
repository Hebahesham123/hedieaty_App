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

  String _currentSortOption = 'status'; // Default sorting by status

  void _sortEvents(String option) {
    setState(() {
      _currentSortOption = option;

      _events.sort((a, b) {
        switch (option) {
          case 'name':
            final nameA = a.name ?? '';
            final nameB = b.name ?? '';
            return nameA.compareTo(nameB);
          case 'category':
            final categoryA = a.category ?? '';
            final categoryB = b.category ?? '';
            return categoryA.compareTo(categoryB);
          case 'status':
            final statusComparison = _getEventStatus(a).compareTo(_getEventStatus(b));
            if (statusComparison != 0) return statusComparison;

            // Secondary sorting by name
            final nameA = a.name ?? '';
            final nameB = b.name ?? '';
            return nameA.compareTo(nameB);
          default:
            return 0;
        }
      });
    });
  }


  @override
  void initState()  {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await _syncEvents();
    final events = await _controller.fetchEvents(widget.userId!);

    // Sort by status, then category, then name
    events.sort((a, b) {
      // Sort by status: Upcoming -> Current -> Past
      final statusComparison = _getEventStatus(a).compareTo(_getEventStatus(b));
      if (statusComparison != 0) return statusComparison;

      // Sort by category (handle nulls with an empty string)
      final categoryA = a.category ?? '';
      final categoryB = b.category ?? '';
      final categoryComparison = categoryA.compareTo(categoryB);
      if (categoryComparison != 0) return categoryComparison;

      // Sort by name (handle nulls with an empty string)
      final nameA = a.name ?? '';
      final nameB = b.name ?? '';
      return nameA.compareTo(nameB);
    });

    setState(() {
      _events = events;
    });
  }


  int _getEventStatus(Event event) {
    final currentDate = DateTime.now();
    final eventDate = event.date != null ? DateTime.tryParse(event.date!) : null;

    if (eventDate == null) {
      // Treat events with invalid or null dates as "Past"
      return 2;
    }

    if (eventDate.isBefore(currentDate)) {
      return 2; // Past
    } else if (eventDate.isAfter(currentDate)) {
      return 0; // Upcoming
    } else {
      return 1; // Current
    }
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
          DropdownButton<String>(
            value: _currentSortOption,
            onChanged: (value) {
              if (value != null) {
                _sortEvents(value);
              }
            },
            items: [
              DropdownMenuItem(
                value: 'name',
                child: Text("Sort by Name"),
              ),
              DropdownMenuItem(
                value: 'category',
                child: Text("Sort by Category"),
              ),
              DropdownMenuItem(
                value: 'status',
                child: Text("Sort by Status"),
              ),
            ],
            icon: Icon(Icons.sort, color: Colors.white),
            dropdownColor: Colors.blueGrey,
            underline: Container(),
          ),
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
