import 'package:flutter/material.dart';
import '../Controllers/friend_controller.dart';
import '../Controllers/signin_controller.dart';
import 'package:hedieaty/EventListPage.dart';
import 'friend_event_list_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FriendController _friendController = FriendController();
  TextEditingController phoneController = TextEditingController();
  final SignInController signInController =  SignInController();
  // String? currentUserUid;
  late Future<String?> _currentUserUidFuture;

  @override
  void initState() {
    super.initState();
    _currentUserUidFuture =  signInController.getUserUID();
    _loadFriends();
  }

  // Load the friends list from the controller
  Future<void> _loadFriends() async {
    String? currentUserUid = await signInController.getUserUID();
    await _friendController.fetchAllFriends(currentUserUid!);
    setState(() {}); // Update the UI after loading friends
  }

  // Show the dialog to add a friend by phone number
  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend'),
          content: TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Enter Phone Number',
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String phoneNumber = phoneController.text;
                String? currentUserUid = await signInController.getUserUID();
                if (phoneNumber.isNotEmpty) {
                  Map<String, dynamic>? friend = await _friendController.searchFriend(phoneNumber);
                  if (friend != null && friend.containsKey('uid')) {
                    String friendUid = friend['uid']; // Get the friend's UID
                    await _friendController.addFriend(currentUserUid!, friendUid);
                    _loadFriends();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Friend not found or UID is missing')),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text('Add Friend'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Friends',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: _showAddFriendDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Colorful Watercolor Painting.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        // Search functionality here
                      },
                      decoration: InputDecoration(
                        hintText: 'Search friends\' gift lists...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Create Event/List Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EventListPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      child: const Text('Create Your Own Event/List'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // List of Friends with Upcoming Events
                  Expanded(
                    child: FutureBuilder(
                      future: _currentUserUidFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Error loading friends'));
                        } else {
                          // Access the friends list through the controller
                          List<Map<String, dynamic>> friends = _friendController.friends;

                          return ListView.builder(
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> friend = friends[index];
                              return Card(
                                color: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: AssetImage('assets/friend_placeholder.jpg'),
                                  ),
                                  title: Text(friend['name']),
                                  subtitle: Text(friend['mobile']),
                                  trailing: FutureBuilder<int>(
                                    future: _friendController.calculateUpcomingEvents(friend['uid']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator(); // Show a loading indicator while fetching data
                                      } else if (snapshot.hasError) {
                                        return const Icon(Icons.error, color: Colors.red); // Show an error icon if something goes wrong
                                      } else {
                                        int upcomingEvents = snapshot.data ?? 0; // Get the result from the Future
                                        return Container(
                                          padding: const EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            color: upcomingEvents > 0 ? Colors.purple[200] : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            upcomingEvents > 0 ? '$upcomingEvents' : '', // Show the count or empty string
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    print("friend id: $friend['uid']");
                                    print("friend name: $friend['name']");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FriendEventListPage(
                                          friendFirebaseId: friend['uid'],
                                          friendName: friend['name'],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
