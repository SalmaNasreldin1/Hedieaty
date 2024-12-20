import '../Models/gift_model.dart';

class GiftController {
  final GiftModel _giftModel = GiftModel();

  Future<List<Map<String, dynamic>>> fetchGifts(String eventId) {
    return _giftModel.fetchGifts(eventId);
  }

  Future<int> addGift(Map<String, dynamic> giftData) async {
    final giftId = await _giftModel.addGift(giftData);

    // Check if the gift is marked as published
    if (giftData['published'] == 1) {
      // Fetch the full gift data (with generated ID) to publish to Firebase
      giftData['id'] = giftId;
      await _giftModel.publishGiftToFirebase(giftData);
    }

    return giftId;
  }

  Future<void> updateGift(int giftId, Map<String, dynamic> updatedData) async {
    // Update in SQLite
    await _giftModel.updateGift(giftId, updatedData);

    // If published, update in Firebase
    if (updatedData['published'] == 1) {
      await _giftModel.publishGiftToFirebase(updatedData);
    }
  }

  Future<void> deleteGift(Map<String, dynamic> giftData) async {
    // Delete from SQLite
    await _giftModel.deleteGift(giftData['id']);

    // If published, delete from Firebase
    if (giftData['published'] == 1 && giftData['firebase_id'] != null) {
      await _giftModel.unpublishGiftFromFirebase(giftData);
    }
  }

  Future<void> publishGift(Map<String, dynamic> giftData) async {
    giftData['published'] = 1;
    await _giftModel.publishGiftToFirebase(giftData);
  }

  Future<void> unpublishGift(Map<String, dynamic> giftData) async {
    giftData['published'] = 0;
    await _giftModel.unpublishGiftFromFirebase(giftData);
  }

  Future<void> deleteGiftsByEvent(String eventId) async {
    await _giftModel.deleteGiftsByEvent(eventId);
  }

  Future<void> pledgeGift(int giftId, String userId) async {
    await _giftModel.updateGift(giftId, {'status': 'pledged', 'pledged_by': userId});
  }

  Future<void> unpledgeGift(int giftId) async {
    await _giftModel.updateGift(giftId, {'status': 'available', 'pledged_by': ''});
  }

  Future<List<Map<String, dynamic>>> fetchGiftsForUser(String userId) async {
    return await _giftModel.fetchGiftsForUser(userId);
  }

  Future<List<Map<String, dynamic>>> fetchGiftsPledgedByUser(String userId) async {
    return await _giftModel.fetchGiftsPledgedByUser(userId);
  }

}
