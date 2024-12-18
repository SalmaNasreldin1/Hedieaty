import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_conn.dart';

class GiftModel {
  final MyDatabaseClass _databaseClass = MyDatabaseClass();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchGifts(String eventId) async {
    final db = await _databaseClass.mydbcheck();
    return await db?.query(
      'Gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    ) ??
        [];
  }

  Future<int> addGift(Map<String, dynamic> giftData) async {
    final db = await _databaseClass.mydbcheck();
    return await db?.insert('Gifts', giftData) ?? 0;
  }

  Future<int> updateGift(int giftId, Map<String, dynamic> updatedData) async {
    final db = await _databaseClass.mydbcheck();
    return await db?.update(
      'Gifts',
      updatedData,
      where: 'id = ?',
      whereArgs: [giftId],
    ) ??
        0;
  }

  Future<int> deleteGift(int giftId) async {
    final db = await _databaseClass.mydbcheck();
    return await db?.delete(
      'Gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    ) ??
        0;
  }

  Future<void> publishGiftToFirebase(Map<String, dynamic> giftData) async {
    if (giftData['firebase_id'] != null) {
      // Update Firestore
      await _firestore.collection('Gifts').doc(giftData['firebase_id']).set(giftData);
    } else {
      // Create Firestore document
      DocumentReference docRef = await _firestore.collection('Gifts').add(giftData);
      giftData['firebase_id'] = docRef.id;

      // Update SQLite with Firestore ID
      final db = await _databaseClass.mydbcheck();
      await db?.update(
        'Gifts',
        {'firebase_id': docRef.id, 'published': 1},
        where: 'id = ?',
        whereArgs: [giftData['id']],
      );
    }
  }

  Future<void> unpublishGiftFromFirebase(Map<String, dynamic> giftData) async {
    if (giftData['firebase_id'] != null) {
      // Delete Firestore document
      await _firestore.collection('Gifts').doc(giftData['firebase_id']).delete();
    }
  }

  Future<void> deleteGiftsByEvent(String eventId) async {
    final db = await _databaseClass.mydbcheck();

    // Fetch related gifts
    final relatedGifts = await fetchGifts(eventId);

    // Delete gifts from Firebase
    for (var gift in relatedGifts) {
      if (gift['firebase_id'] != null) {
        await _firestore.collection('Gifts').doc(gift['firebase_id']).delete();
      }
    }

    // Delete gifts from SQLite
    await db?.delete(
      'Gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }
}
