import 'package:flutter/material.dart';
import 'MyPledgedGiftsPage.dart';

class ProfilePage extends StatelessWidget {
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
          // Foreground with subpage content
          SafeArea(
            child: Column(
              children: [
                // Profile Picture and Name
                const SizedBox(height: 50),
                const Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/profile_pic.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Salma Nasreldin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Subpage container with options
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
                          icon: Icons.person,
                          title: 'Your Profile',
                          onTap: () {
                            // Navigate to Profile Details page
                          },
                        ),
                        ProfileOptionItem(
                          icon: Icons.settings,
                          title: 'Settings',
                          onTap: () {
                            // Navigate to Settings page
                          },
                        ),
                        ProfileOptionItem(
                          icon: Icons.event,
                          title: 'My Events',
                          onTap: () {
                            // Navigate to Events page
                          },
                        ),
                        ProfileOptionItem(
                          icon: Icons.card_giftcard,
                          title: 'My Pledged Gifts',
                          onTap: () {
                            // Navigate to My Pledged Gifts page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyPledgedGiftsPage()),
                            );
                          },
                        ),
                        ProfileOptionItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: () {
                            // Handle logout logic
                          },
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

// Widget for Profile Option Items with an icon on the left
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
      leading: Icon(icon, color: Colors.purple.shade300), // Left icon
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}
