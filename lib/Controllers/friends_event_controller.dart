import '../Models/event_model.dart';

class FriendEventController {
  final EventModel _eventModel = EventModel();

  Future<List<Map<String, dynamic>>> fetchFriendEvents(String friendFirebaseId) async {
    return await _eventModel.getFriendEvents(friendFirebaseId);
  }
}
