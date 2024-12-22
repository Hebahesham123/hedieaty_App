import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    print(dbPath);
    final path = join(dbPath, 'mmxx.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Users (
      uid TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      mobile TEXT NOT NULL UNIQUE,
      preferences TEXT
    );
  ''');

    await db.execute('''
    CREATE TABLE Events (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      date TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT,
      category TEXT,
      published INTEGER NOT NULL CHECK (published IN (0, 1)),
      user_id text NOT NULL,
      FOREIGN KEY (user_id) REFERENCES Users (uid) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE Gifts (
      id Text PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT NOT NULL,
      price REAL NOT NULL,
      status TEXT NOT NULL,
      published INTEGER NOT NULL CHECK (published IN (0, 1)),
      event_id Text NOT NULL,
      firestoreId Text,
      imageLink Text,
      pledgedBy Text,
      FOREIGN KEY (event_id) REFERENCES Events (id) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE Friends (
      user_id Text NOT NULL,
      friend_id Text NOT NULL,
      PRIMARY KEY (user_id, friend_id)
    );
  ''');
  }


  // uid TEXT NULL,
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
