import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hediaty_appp/Databases/database_helper.dart';

class FriendModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Add Friend to SQLite
  Future<void> saveFriendToLocal(String userId, String friendId) async {
    final db = await _dbHelper.database;
    await db.insert(
      'Friends',
      {'user_id': userId, 'friend_id': friendId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Add Friend to Firestore
  Future<void> saveFriendToRemote(String userId, String friendId) async {
    await _firestore.collection('users').doc(userId).update({
      'friends': FieldValue.arrayUnion([friendId]),
    });

    await _firestore.collection('users').doc(friendId).update({
      'friends': FieldValue.arrayUnion([userId]),
    });
  }

  // Fetch Friends from SQLite
  Future<List<String>> fetchFriendsFromLocal(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'Friends',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((row) => row['friend_id'] as String).toList();
  }

  // Sync Friends from Firestore to SQLite
  Future<void> syncFriends(String userId) async {
    final db = await _dbHelper.database;

    // Fetch friends from Firestore
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final List<String> friends = List<String>.from(userDoc['friends'] ?? []);

    // Clear existing friends in SQLite
    await db.delete('Friends', where: 'user_id = ?', whereArgs: [userId]);

    // Insert fetched friends into SQLite
    for (final friendId in friends) {
      await db.insert(
        'Friends',
        {'user_id': userId, 'friend_id': friendId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Search for Friend by Phone
  Future<Map<String, dynamic>?> searchFriendByPhone(String phone) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('mobile', isEqualTo: phone)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null; // No user found
    }

    return querySnapshot.docs.first.data(); // Return the user's data
  }
}
