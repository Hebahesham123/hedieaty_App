import 'package:hediaty_appp/Classes/Event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hediaty_appp/Databases/database_helper.dart';

class EventModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Save Event to SQLite
  Future<void> saveToLocal(Event event) async {
    final db = await _dbHelper.database;
    await db.insert('Events', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Save Event to Firestore
  Future<void> saveToRemote(Event event) async {
    await _firestore.collection('events').doc(event.id).set(event.toMap());
  }

  // Update Event in SQLite
  Future<void> updateEventInLocal(Event event) async {
    final db = await _dbHelper.database;
    await db.update(
      'Events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  // Update Event in Firestore
  Future<void> updateEventInRemote(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  // Delete Event from SQLite
  Future<void> deleteFromLocal(String eventId) async {
    final db = await _dbHelper.database;
    await db.delete('Events', where: 'id = ?', whereArgs: [eventId]);
  }

  // Delete Event from Firestore
  Future<void> deleteFromRemote(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  // Fetch Events by User ID from SQLite
  Future<List<Event>> fetchEventsByUser(String userId) async {
    final db = await _dbHelper.database;
    final result =
    await db.query('Events', where: 'user_id = ?', whereArgs: [userId]);

    return result.map((map) => Event.fromMap(map)).toList();
  }

  Future<Event?> getEventById(String eventId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'Events',
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (result.isNotEmpty) {
      return Event.fromMap(result.first);
    }

    return null; // Return null if no matching event is found
  }

  // Fetch all events for a user from Firestore
  Future<List<Event>> fetchAllEventsFromRemote(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('user_id', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Event.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching events from Firestore: $e");
      return [];
    }
  }

  // Sync Firestore events with local SQLite
  Future<void> syncEventsWithLocal(String userId) async {
    final db = await _dbHelper.database;

    // Fetch all events from Firestore
    final remoteEvents = await fetchAllEventsFromRemote(userId);

    for (final remoteEvent in remoteEvents) {
      // Check if the event exists in SQLite
      final existingEvent = await db.query(
        'Events',
        where: 'id = ?',
        whereArgs: [remoteEvent.id],
      );

      if (existingEvent.isEmpty) {
        // Add to SQLite if not found
        await db.insert('Events', remoteEvent.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        print("Event with ID ${remoteEvent.id} added to SQLite.");
      } else {
        // Update in SQLite if found
        await db.update(
          'Events',
          remoteEvent.toMap(),
          where: 'id = ?',
          whereArgs: [remoteEvent.id],
        );
        print("Event with ID ${remoteEvent.id} updated in SQLite.");
      }
    }
  }

}
