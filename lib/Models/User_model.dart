import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hediaty_appp/Classes/User.dart';
import 'package:hediaty_appp/Databases/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class UserModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Save User to SQLite
  Future<void> saveToLocal(User user) async {
    final db = await _dbHelper.database;
    await db.insert('Users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch User by UID from SQLite
  Future<User?> getFromLocal(String uid) async {
    final db = await _dbHelper.database;
    final result = await db.query('Users', where: 'uid = ?', whereArgs: [uid]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Save User to Firestore
  Future<void> saveToRemote(User user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  // Fetch User by UID from Firestore
  Future<User?> getFromRemote(String uid) async {
    print("Fetching data for UID: $uid");

    final document = await _firestore.collection('users').doc(uid).get();
    print("OOOOOOOOOOOOOOOOO");
    print(document.data());
    if (document.exists) {
      return User.fromMap(document.data()!);
    }
    return null;
  }

  // Fetch Current User Profile
  Future<User?> getCurrentUserProfile(String uid) async {
    // Attempt to fetch user from local SQLite
    User? user = await getFromLocal(uid);
    if (user != null) {
      return user;
    }

    // If not found locally, fetch from Firestore
    user = await getFromRemote(uid);
    if (user != null) {
      // Save the fetched user to local SQLite
      await saveToLocal(user);
    }
    return user;
  }
}
