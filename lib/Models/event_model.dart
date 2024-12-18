import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_conn.dart';

class EventModel {
  final MyDatabaseClass _dbHelper = MyDatabaseClass();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await _dbHelper.mydbcheck();
    String? uid = await _secureStorage.read(key: 'userUID');
    if (uid == null) return []; // No UID found in storage

    return await db!.query(
      'Events',
      where: 'user_id = ?',
      whereArgs: [uid],
    );
  }

  Future<int> addEvent(Map<String, dynamic> eventData) async {
    final db = await _dbHelper.mydbcheck();
    return await db!.insert('Events', eventData);
  }


  Future<void> updateEvent(int id, Map<String, dynamic> eventData) async {
    final db = await _dbHelper.mydbcheck();
    await db!.update(
      'Events',
      eventData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEvent(int id,Map<String, dynamic> eventData) async {
    if( eventData['firebase_id'] != null){
      unpublishEventFromFirebase(eventData);
    }
    final db = await _dbHelper.mydbcheck();
    await db!.delete(
      'Events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> publishEventToFirebase(Map<String, dynamic> eventData) async {
    final db = await _dbHelper.mydbcheck();

    if (eventData['firebase_id'] != null) {
      // Update existing Firestore document
      await _firestore
          .collection('Events')
          .doc(eventData['firebase_id'])
          .set(eventData);

      if (eventData['id'] != null) {
        await db!.update(
          'Events',
          {'published': 1},
          where: 'id = ?',
          whereArgs: [eventData['id']],
        );
      } else {
        throw Exception("Event ID is null. Cannot update SQLite with Firebase ID.");
      }
    } else {
      // Create a new Firestore document
      DocumentReference docRef = await _firestore.collection('Events').add(eventData);
      eventData['firebase_id'] = docRef.id;

      // Save Firestore ID in SQLite
      if (eventData['id'] != null) {
        await db!.update(
          'Events',
          {'firebase_id': docRef.id, 'published': 1},
          where: 'id = ?',
          whereArgs: [eventData['id']],
        );
      } else {
        throw Exception("Event ID is null. Cannot update SQLite with Firebase ID.");
      }
    }
  }



  Future<void> unpublishEventFromFirebase(Map<String, dynamic> eventData) async {
    final db = await _dbHelper.mydbcheck();

    if (eventData['firebase_id'] != null) {
      // Delete Firestore document
      await _firestore.collection('Events').doc(eventData['firebase_id']).delete();

      // Update SQLite: Set published to 0 but retain firebase_id
      await db!.update(
        'Events',
        {'published': 0}, // Only update the published field
        where: 'id = ?',
        whereArgs: [eventData['id']],
      );
    }
  }

}
