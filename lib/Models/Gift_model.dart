import 'package:hediaty_appp/Classes/Gift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hediaty_appp/Databases/database_helper.dart';

class GiftModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Save Gift to SQLite
  Future<void> saveToLocal(Gift gift) async {
    final db = await _dbHelper.database;
    await db.insert('Gifts', gift.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Save Gift to Firestore
  Future<void> saveToRemote(Gift gift) async {
    await _firestore.collection('gifts').doc(gift.id.toString()).set(gift.toMap());
  }

  // Update Gift in SQLite
  Future<void> updateGiftInLocal(Gift gift) async {
    final db = await _dbHelper.database;
    await db.update(
      'Gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  // Delete Gift from SQLite
  Future<void> deleteFromLocal(String giftId) async {
    final db = await _dbHelper.database;
    await db.delete('Gifts', where: 'id = ?', whereArgs: [giftId]);
  }

  // Delete Gift from Firestore
  Future<void> deleteFromRemote(String giftId) async {
    await _firestore.collection('gifts').doc(giftId.toString()).delete();
  }

  // Fetch Gifts by Event ID from SQLite
  Future<List<Gift>> fetchGiftsByEvent(String eventId) async {
    final db = await _dbHelper.database;
    final result =
    await db.query('Gifts', where: 'event_id = ?', whereArgs: [eventId]);

    return result.map((map) => Gift.fromMap(map)).toList();
  }

  // Sync Firestore gifts with local SQLite
  Future<void> syncGiftsWithLocal(String eventId) async {
    final db = await _dbHelper.database;

    // Fetch all gifts from Firestore
    final querySnapshot = await _firestore
        .collection('gifts')
        .where('event_id', isEqualTo: eventId)
        .get();

    for (final doc in querySnapshot.docs) {
      final remoteGift = Gift.fromMap(doc.data());

      // Check if the gift exists in SQLite
      final existingGift = await db.query(
        'Gifts',
        where: 'id = ?',
        whereArgs: [remoteGift.id],
      );

      if (existingGift.isEmpty) {
        // Add to SQLite if not found
        await db.insert('Gifts', remoteGift.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        // Update in SQLite if found
        await db.update(
          'Gifts',
          remoteGift.toMap(),
          where: 'id = ?',
          whereArgs: [remoteGift.id],
        );
      }
    }
  }

  Future<Gift?> getGiftById(String giftId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'Gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );

    if (result.isNotEmpty) {
      return Gift.fromMap(result.first);
    }

    return null; // Return null if no matching gift is found
  }
}
