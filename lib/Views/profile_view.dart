import 'package:flutter/material.dart';
import 'my_event_list_view.dart';
import '../Controllers/signin_controller.dart';
import 'pledged_gifts_view.dart';
import 'signin_view.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SignInController _signInController = SignInController();
  String? userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String? userUID = await _signInController.getUserUID();
    if (userUID != null) {
      String? fetchedName = await _signInController.fetchUserName(userUID);
      setState(() {
        userName = fetchedName ?? "Unknown User";
      });
    }
  }

  void _logOut() async {
    // Clear user session data and navigate to login screen
    await _signInController.logout();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    ); // Adjust route if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white),
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
          // Foreground content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                // Profile Picture and Name
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/friend_placeholder.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  userName ?? "Loading...",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Options Container
                Expanded(
                  child: Container(
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ProfileOptionItem(
                          icon: Icons.event,
                          title: 'My Events',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EventListPage()),
                            );
                          },
                        ),
                        ProfileOptionItem(
                          icon: Icons.card_giftcard,
                          title: 'My Pledged Gifts',
                          onTap: () async {
                            String? userUID = await _signInController.getUserUID();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PledgedGiftsPage(userId: userUID!)),
                            );
                          },
                        ),
                        ProfileOptionItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: _logOut,
                        ),
                      ],
                    ),
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

// Widget for Profile Option Items
class ProfileOptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOptionItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple.shade300),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}
