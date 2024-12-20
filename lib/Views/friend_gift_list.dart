import 'package:flutter/material.dart';
import '../Controllers/friend_gift_controller.dart';
import 'friend_gift_details.dart';
import '../Controllers/signin_controller.dart';

class FriendGiftListPage extends StatefulWidget {
  final String friendEventId;
  final String friendEventName;

  const FriendGiftListPage({
    Key? key,
    required this.friendEventId,
    required this.friendEventName,
  }) : super(key: key);

  @override
  _FriendGiftListPageState createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  final FriendGiftController _friendGiftController = FriendGiftController();
  final SignInController signInController = SignInController();
  List<Map<String, dynamic>> gifts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    final data = await _friendGiftController.fetchFriendGifts(widget.friendEventId);
    setState(() {
      gifts = data;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filteredGifts = gifts;

    // Apply the search query
    if (searchQuery.isNotEmpty) {
      filteredGifts = filteredGifts
          .where((gift) =>
          gift['name'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Update the displayed gifts
    setState(() {
      gifts = filteredGifts;
    });
  }


  void _togglePledgeStatus(Map<String, dynamic> gift, int index, String userId) async {
    final isPledged = gift['status'] == 'pledged';

    try {
      // Update the status in Firebase
      await _friendGiftController.togglePledgeStatus(gift['id'], !isPledged, userId);

      // Update the local state after a successful Firebase update
      setState(() {
        gifts[index]['status'] = !isPledged ? 'pledged' : 'available';
        gifts[index]['pledged_by'] = !isPledged ? userId : ''; // Update local data
        print(gift);
      });
    } catch (e) {
      // Handle errors (e.g., network issues)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating pledge status: $e')),
      );
    }
  }



  void _navigateToGiftDetails(Map<String, dynamic> gift) async {
    final updatedGift = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendGiftDetailsPage(gift: gift),
      ),
    );

    if (updatedGift != null) {
      setState(() {
        final index = gifts.indexWhere((g) => g['id'] == updatedGift['id']);
        if (index != -1) {
          gifts[index] = updatedGift;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Gifts for ${widget.friendEventName}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Gifts...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          itemCount: gifts.length,
                          itemBuilder: (context, index) {
                            final gift = gifts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                leading: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: gift['imageLink'] != null
                                          ? NetworkImage(gift['imageLink'])
                                          : const AssetImage('assets/gift_placeholder.png')
                                      as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                    color: Colors.grey[200],
                                  ),
                                ),
                                title: Text(gift['name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Category: ${gift['category']}'),
                                    Text('Price: \$${gift['price']}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.card_giftcard,
                                    color: gift['status'] == 'pledged'
                                        ? Colors.orangeAccent
                                        : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    try {
                                      // Retrieve the user's Firebase ID asynchronously
                                      final userId = await signInController.getUserUID(); // Replace with your actual future function

                                      // Call the _togglePledgeStatus function with the retrieved user ID
                                      _togglePledgeStatus(gift,index,userId!);
                                    } catch (e) {
                                      // Handle potential errors
                                      print (e);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: ${e.toString()}')),
                                      );
                                    }
                                  } ,
                                ),
                                onTap: () => _navigateToGiftDetails(gift),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
