import 'package:hediaty_appp/Controllers/Gift_controller.dart';
import 'package:hediaty_appp/Models/Event_model.dart';
import 'package:uuid/uuid.dart';
import 'package:hediaty_appp/Classes/Event.dart';
import 'package:hediaty_appp/Models/Gift_model.dart';
import 'package:hediaty_appp/Classes/Gift.dart';
import 'package:hediaty_appp/Controllers/Gift_controller.dart';
class EventController {
  final EventModel _eventModel = EventModel();
  final Uuid _uuid = Uuid();
  final GiftModel _giftModel = GiftModel();
  final GiftController _giftController = GiftController();

  // Create Event
  Future<void> createEvent({
    required String name,
    required String date,
    required String location,
    required String userId,
    String? description,
    String? category,
  }) async {
    String eventId = _uuid.v4();

    Event event = Event(
      id: eventId,
      name: name,
      date: date,
      location: location,
      description: description,
      category: category,
      published: false,
      userId: userId,
    );

    await _eventModel.saveToLocal(event);
    if(event.published){
      await _eventModel.saveToRemote(event);
    }

    print("Event created successfully!");
  }

  // Update Event
  Future<void> updateEvent(Event event) async {
    await _eventModel.updateEventInLocal(event);
    if(event.published) {
      await _eventModel.updateEventInRemote(event);
    }
    print("Event updated successfully!");
  }

  // Delete Event
  Future<void> deleteEvent(String eventId) async {
    await _eventModel.deleteFromLocal(eventId);
    await _eventModel.deleteFromRemote(eventId);

    print("Event deleted successfully!");
  }

  Future<void> togglePublishedStatus(String eventId, int newStatus) async {
    // Fetch the event by eventId
    final event = await _eventModel.getEventById(eventId);

    if (event == null) {
      print("Error: Event with ID $eventId not found.");
      return;
    }

    // Update SQLite
    final updatedEvent = Event(
      id: event.id,
      name: event.name,
      date: event.date,
      location: event.location,
      description: event.description,
      category: event.category,
      published: newStatus == 1, // Update published status
      userId: event.userId,
    );

    await _eventModel.updateEventInLocal(updatedEvent);
    if(updatedEvent.published){
      await _eventModel.saveToRemote(updatedEvent);
    }else{
      await _eventModel.deleteFromRemote(updatedEvent.id);
    }

    // Handle gifts if event is unpublished
    if (newStatus == 0) {
      final gifts = await _giftController.fetchGifts(eventId);
      if(gifts.isNotEmpty) {
        for (final gift in gifts) {
          final updatedGift = Gift(
            id: gift.id,
            name: gift.name,
            description: gift.description,
            category: gift.category,
            price: gift.price,
            status: gift.status,
            published: false,
            // Unpublish gift
            eventId: gift.eventId,
            imageLink: gift.imageLink,
          );
          await _giftController.updateGift(updatedGift);
          await _giftModel.deleteFromRemote(gift.id!);
        }
      }
      print("All gifts unpublished for event ID $eventId.");
    } else {
      print("Event with ID $eventId published.");
    }

    print("Event publish status updated locally to $newStatus for event ID $eventId!");
  }




  // Fetch Events
  Future<List<Event>> fetchEvents(String userId) async {
    return await _eventModel.fetchEventsByUser(userId);
  }

  // Sync Firestore events with local SQLite
  Future<void> syncEvents(String userId) async {
    await _eventModel.syncEventsWithLocal(userId);
  }
}
