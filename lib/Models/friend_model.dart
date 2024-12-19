import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search for a user by phone number in Firebase
  Future<Map<String, dynamic>?> searchFriendByPhoneNumber(String phoneNumber) async {
    QuerySnapshot querySnapshot = await _firestore.collection('Users')
        .where('mobile', isEqualTo: phoneNumber)  // Querying the correct field 'mobile'
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    }
    return null;
  }

  // Add a friend to the user's and the friend's friends array in Firebase
  Future<void> addFriend(String currentUserUid, String friendUid) async {
    try {
      // Reference to current user and friend in Firestore
      final userRef = _firestore.collection('Users').doc(currentUserUid);
      final friendRef = _firestore.collection('Users').doc(friendUid);

      // Check if the current user's document exists
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        // If user doesn't exist, create the user document
        await userRef.set({
          'uid': currentUserUid,
          'friends': [],
          // Add other necessary user fields here (e.g., name, mobile, etc.)
        });
      }

      // Check if the friend's document exists
      DocumentSnapshot friendDoc = await friendRef.get();
      if (!friendDoc.exists) {
        // If friend doesn't exist, you can choose to handle it differently (maybe show an error)
        throw Exception("Friend not found in Firebase");
      }

      // Update the friends array for the current user and the friend
      await userRef.update({
        'friends': FieldValue.arrayUnion([friendUid]),
      });

      await friendRef.update({
        'friends': FieldValue.arrayUnion([currentUserUid]),
      });
    } catch (e) {
      print("Error adding friend: $e");
      throw e; // Rethrow the error to handle it in the controller
    }
  }

  // Fetch all friends for a specific user from Firebase (using UID)
  Future<List<Map<String, dynamic>>> fetchAllFriends(String userUid) async {
    final userDoc = await _firestore.collection('Users').doc(userUid).get();
    List<String> friendUids = List<String>.from(userDoc['friends'] ?? []);
    List<Map<String, dynamic>> friends = [];

    for (String friendUid in friendUids) {
      DocumentSnapshot friendDoc = await _firestore.collection('Users').doc(friendUid).get();
      friends.add(friendDoc.data() as Map<String, dynamic>);
    }

    print(friends);

    return friends;
  }
  Future<List<Map<String, dynamic>>> fetchEventsForFriend(String friendUid) async {
    QuerySnapshot eventsSnapshot = await _firestore
        .collection('Events')
        .where('user_id', isEqualTo: friendUid)
        .get();

    return eventsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }


}
