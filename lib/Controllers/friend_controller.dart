import '../Models/friend_model.dart';

class FriendController {
  final FriendModel _friendModel = FriendModel();
  List<Map<String, dynamic>> _friends = [];

  // Getter to access the list of friends
  List<Map<String, dynamic>> get friends => _friends;

  // Search for a friend by phone number
  Future<Map<String, dynamic>?> searchFriend(String phoneNumber) async {
    return await _friendModel.searchFriendByPhoneNumber(phoneNumber);
  }

  Future<void> addFriend(String currentUserUid, String friendUid) async {
    try {
      print("friend: $friendUid");
      print("user: $currentUserUid");
      await _friendModel.addFriend(currentUserUid, friendUid);
      await fetchAllFriends(currentUserUid);// Refresh friends list
    } catch (e) {
      print("Error adding friend: $e");
      throw e; // Handle error, maybe show a message in the UI
    }
  }

  // Fetch all friends for a specific user
  Future<void> fetchAllFriends(String userUid) async {
    _friends = await _friendModel.fetchAllFriends(userUid);
  }

  Future<int> calculateUpcomingEvents(String friendUid) async {
    List<Map<String, dynamic>> friendEvents = await _friendModel.fetchEventsForFriend(friendUid);

    DateTime today = DateTime.now();
    int upcomingEventsCount = 0;

    for (var event in friendEvents) {
      DateTime eventDate = DateTime.parse(event['date']);
      DateTime eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
      DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

      if (eventDateOnly.isAfter(todayDateOnly)) {
        upcomingEventsCount++;
      }
    }

    return upcomingEventsCount;
  }

}


