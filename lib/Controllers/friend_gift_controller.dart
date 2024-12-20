import '../Models/friend_gift_model.dart';

class FriendGiftController {
  final FriendGiftModel _friendGiftModel = FriendGiftModel();

  Future<List<Map<String, dynamic>>> fetchFriendGifts(String friendEventId) {
    return _friendGiftModel.fetchFriendGifts(friendEventId);
  }

  Future<Map<String, dynamic>?> fetchFriendGiftDetails(String giftId) {
    return _friendGiftModel.fetchFriendGiftDetails(giftId);
  }

  Future<void> togglePledgeStatus(String giftId, bool isPledged, String userId) {
    return _friendGiftModel.togglePledgeStatus(giftId, isPledged, userId);
  }

}
