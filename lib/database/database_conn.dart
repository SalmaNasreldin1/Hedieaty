import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabaseClass {
  Database? mydb;

  Future<Database?> mydbcheck() async {
    if (mydb == null) {
      mydb= await initiatedatabase();
      return mydb;
    }else {
      return mydb;
    }
  }
  
  int Version = 1;
  initiatedatabase() async {
    String databasedestination = await getDatabasesPath();
    String databasepath  = join(databasedestination,'database.db');
    Database mydatabase1 = await openDatabase(
      databasepath,
      version: Version,
      onCreate: _onCreate,
    );
    return mydatabase1;
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
      id INTEGER PRIMARY KEY AUTOINCREMENT,
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
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT NOT NULL,
      price REAL NOT NULL,
      status TEXT NOT NULL,
      published INTEGER NOT NULL CHECK (published IN (0, 1)),
      event_id INTEGER NOT NULL,
      FOREIGN KEY (event_id) REFERENCES Events (id) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE Friends (
      user_id INTEGER NOT NULL,
      friend_id INTEGER NOT NULL,
      PRIMARY KEY (user_id, friend_id),
      FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE
    );
  ''');
  }


  // uid TEXT NULL,
  Future<void> closeDatabase() async {
    final db = await mydb;
    await db?.close();
  }
}