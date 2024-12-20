import 'package:cloud_firestore/cloud_firestore.dart';

class FriendGiftModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchFriendGifts(String friendEventId) async {
    QuerySnapshot giftsSnapshot = await _firestore
        .collection('Gifts')
        .where('event_id', isEqualTo: friendEventId)
        .where('status', isEqualTo: 'available')
        .get();

    return giftsSnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add Firebase document ID for reference
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>?> fetchFriendGiftDetails(String giftId) async {
    DocumentSnapshot giftDoc = await _firestore.collection('Gifts').doc(giftId).get();
    return giftDoc.exists ? giftDoc.data() as Map<String, dynamic> : null;
  }

  Future<void> togglePledgeStatus(String giftId, bool isPledged, String userId) async {
    await _firestore.collection('Gifts').doc(giftId).update({
      'status': isPledged ? 'pledged' : 'available',
      'pledged_by': isPledged ? userId : '', // Set userId if pledged, empty string if unpledged
    });
  }

}
