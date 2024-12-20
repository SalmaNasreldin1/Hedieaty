import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_conn.dart';
import 'package:intl/intl.dart';


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

    // Update SQLite database
    int result = await db?.update(
      'Gifts',
      updatedData,
      where: 'id = ?',
      whereArgs: [giftId],
    ) ?? 0;

    // Update Firestore based on status
    if (updatedData['firebase_id'] != null) {
      if (updatedData['status'] == 'pledged') {
        await _firestore
            .collection('Gifts')
            .doc(updatedData['firebase_id'])
            .set({'pledged_by': updatedData['pledged_by']},SetOptions(merge: true));
      } else {
        await _firestore
            .collection('Gifts')
            .doc(updatedData['firebase_id'])
            .set({'pledged_by': ''},SetOptions(merge: true));
      }
    }


    return result; // Return the SQLite update result
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

  Future<List<Map<String, dynamic>>> fetchGiftsForUser(String userId) async {
    try {
      // Fetch events created by the user
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where('user_id', isEqualTo: userId)
          .get();

      // Debugging: Log events
      print("Events fetched: ${eventsSnapshot.docs.map((doc) => doc.data()).toList()}");
      print("Event types: ${eventsSnapshot.docs.map((doc) => doc.data().runtimeType).toList()}");

      List<Map<String, dynamic>> events = eventsSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();

      // Extract event IDs and map them with their dates
      Map<String, dynamic> eventDetails = {
        for (var event in events)
          event['firebase_id']: {
            'date': event['date'], // Assuming 'date' is the event deadline
          }
      };

      // Debugging: Log event details
      print("Event details mapped: $eventDetails");
      print("Event details types: ${eventDetails.values.map((v) => v.runtimeType).toList()}");

      if (eventDetails.isEmpty) {
        return [];
      }

      // Fetch gifts associated with the events
      QuerySnapshot eventGiftsSnapshot = await FirebaseFirestore.instance
          .collection('Gifts')
          .where('event_id', whereIn: eventDetails.keys.toList())
          .where('status', whereIn: ['pledged', 'purchased'])
          .get();

      // Debugging: Log gifts
      print("Gifts fetched: ${eventGiftsSnapshot.docs.map((doc) => doc.data()).toList()}");
      print("Gift types: ${eventGiftsSnapshot.docs.map((doc) => doc.data().runtimeType).toList()}");

      // Extract `pledgedBy` user IDs
      Set<String> userIds = eventGiftsSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['pledged_by'].toString()) // Ensure String
          .toSet();

      // Debugging: Log user IDs
      print("User IDs: $userIds");

      // Fetch user details for the `pledgedBy` users
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where(FieldPath.documentId, whereIn: userIds.toList())
          .get();

      // Debugging: Log user details
      print("Users fetched: ${usersSnapshot.docs.map((doc) => doc.data()).toList()}");
      print("User types: ${usersSnapshot.docs.map((doc) => doc.data().runtimeType).toList()}");

      Map<String, String> userDetails = {
        for (var doc in usersSnapshot.docs)
          doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
      };

      // Map the gifts to include the pledger's name and event deadline
      List<Map<String, dynamic>> eventGifts = eventGiftsSnapshot.docs.map((doc) {
        Map<String, dynamic> giftData = doc.data() as Map<String, dynamic>;
        String eventId = giftData['event_id'].toString(); // Ensure String
        String pledgedById = giftData['pledged_by'].toString(); // Ensure String

        // Handle the deadline based on the type
        dynamic rawDate = eventDetails[eventId]?['date'];
        String deadline = 'Unknown';

        if (rawDate != null) {
          try {
            if (rawDate is Timestamp) {
              // If Firestore Timestamp
              deadline = DateFormat('yyyy-MM-dd').format(rawDate.toDate());
            } else if (rawDate is int) {
              // If Unix timestamp (milliseconds)
              deadline = DateFormat('yyyy-MM-dd')
                  .format(DateTime.fromMillisecondsSinceEpoch(rawDate));
            } else if (rawDate is String) {
              // If already a string
              deadline = rawDate;
            }
          } catch (e) {
            print('Error processing date for event ID $eventId: $e');
          }
        }

        return {
          'id': doc.id,
          ...giftData,
          'Deadline': deadline, // Include the processed deadline
          'PledgedByName': userDetails[pledgedById] ?? 'Unknown', // Add the pledger's name
        };
      }).toList();

      // Debugging: Log the final result
      print("Final event gifts: $eventGifts");
      return eventGifts;
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }



  Future<List<Map<String, dynamic>>> fetchGiftsPledgedByUser(String userId) async {
    try {
      // Fetch pledged gifts by the user
      QuerySnapshot pledgedGiftsSnapshot = await FirebaseFirestore.instance
          .collection('Gifts')
          .where('pledged_by', isEqualTo: userId)

          .get();

      List<Map<String, dynamic>> pledgedGifts = pledgedGiftsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      if (pledgedGifts.isEmpty) {
        return [];
      }

      // Extract event IDs
      Set<String> eventIds = pledgedGifts.map((gift) => gift['event_id'] as String).toSet();

      // Fetch events
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where(FieldPath.documentId, whereIn: eventIds.toList())
          .get();

      Map<String, dynamic> eventDetails = {
        for (var doc in eventsSnapshot.docs)
          doc.id: {
            'date': (doc.data() as Map<String, dynamic>)['date'] ?? 'Unknown',
            'user_id': (doc.data() as Map<String, dynamic>)['user_id'] ?? 'Unknown',
          }
      };

      // Fetch user details of event creators
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where(FieldPath.documentId,
          whereIn: eventDetails.values.map((e) => e['user_id']).toSet().toList())
          .get();

      Map<String, String> userDetails = {
        for (var doc in usersSnapshot.docs)
          doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
      };

      // Map gifts to include recipient name and event deadline
      List<Map<String, dynamic>> allGifts = pledgedGifts.map((gift) {
        String eventId = gift['event_id'];
        String recipientId = eventDetails[eventId]?['user_id'] ?? 'Unknown';

        // Format the deadline
        String deadline = 'Unknown';
        if (eventDetails[eventId]?['date'] != null &&
            eventDetails[eventId]['date'].toString().isNotEmpty) {
          try {
            DateTime parsedDate = DateTime.parse(eventDetails[eventId]['date']);
            deadline = DateFormat('yyyy-MM-dd').format(parsedDate);
          } catch (e) {
            print('Error parsing date for event ID $eventId: $e');
          }
        }

        return {
          ...gift,
          'Deadline': deadline, // Include formatted event deadline
          'OwnerName': userDetails[recipientId] ?? 'Unknown', // Include recipient's name
        };
      }).toList();

      return allGifts;
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }

}
