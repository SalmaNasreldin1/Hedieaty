import 'package:flutter/material.dart';
import '../Controllers/friend_gift_controller.dart';
import '../Controllers/signin_controller.dart';

class FriendGiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic> gift;

  const FriendGiftDetailsPage({Key? key, required this.gift}) : super(key: key);

  @override
  _FriendGiftDetailsPageState createState() => _FriendGiftDetailsPageState();
}

class _FriendGiftDetailsPageState extends State<FriendGiftDetailsPage> {
  final FriendGiftController _friendGiftController = FriendGiftController();
  final SignInController signInController = SignInController();
  bool isPledged = false;

  @override
  void initState() {
    super.initState();
    isPledged = widget.gift['status'] == 'pledged';
  }

  Future<void> _togglePledgeStatus(String userId) async {
    try {
      await _friendGiftController.togglePledgeStatus(widget.gift['firebase_id'], !isPledged, userId);
      setState(() {
        isPledged = !isPledged;
        widget.gift['pledged_by'] = isPledged ? userId : ''; // Update local gift data
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPledged ? 'Pledged successfully!' : 'Unpledged successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gift['name'])),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gift Image
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: widget.gift['imageLink'] != null
                          ? NetworkImage(widget.gift['imageLink'])
                          : const AssetImage('assets/gift_placeholder.png')
                      as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gift Details
              _buildReadOnlyField('Gift Name', widget.gift['name']),
              _buildReadOnlyField('Description', widget.gift['description'] ?? 'No description'),
              _buildReadOnlyField('Category', widget.gift['category']),
              _buildReadOnlyField('Price', '\$${widget.gift['price']}'),

              const SizedBox(height: 20),

              // Pledge Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      // Retrieve the user's Firebase ID asynchronously
                      final userId = await signInController.getUserUID(); // Replace with your actual future function

                      // Call the _togglePledgeStatus function with the retrieved user ID
                      _togglePledgeStatus(userId!);
                    } catch (e) {
                      // Handle potential errors
                      print (e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  } ,
                  icon: Icon(
                    Icons.card_giftcard,
                    color: isPledged ? Colors.deepPurple : Colors.orangeAccent,
                  ),
                  label: Text(isPledged ? 'Unpledge Gift' : 'Pledge Gift'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPledged ? Colors.orangeAccent : Colors.grey,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
