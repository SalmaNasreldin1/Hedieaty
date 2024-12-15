// import 'package:flutter/material.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   List<Friend> friends = [
//     Friend(name: 'John Doe', profilePic: 'assets/john.jpg', upcomingEvents: 1),
//     Friend(name: 'Jane Smith', profilePic: 'assets/jane.jpg', upcomingEvents: 2),
//     Friend(name: 'Sarah Lee', profilePic: 'assets/sarah.jpg', upcomingEvents: 0),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true, // Allows gradient to go behind the status bar
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           'Friends',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_add,color: Colors.white,),
//             onPressed: () {
//               // Add Friend button logic here
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Gradient background covering up to the search bar
//           Container(
//           height: 180, // Increase height to ensure gradient covers the top portion
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.purple.shade300,
//                   Colors.orange.shade200,
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           // Foreground content
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Search Bar
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search friends\' gift lists...',
//                       prefixIcon: const Icon(Icons.search),
//                       fillColor: Colors.white,
//                       filled: true,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       // Search functionality logic here
//                     },
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Create Event/List Button
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/createEvent');
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange.shade200,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
//                       ),
//                       child: const Text('Create Your Own Event/List'),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // List of Friends with Upcoming Events
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: friends.length,
//                       itemBuilder: (context, index) {
//                         Friend friend = friends[index];
//                         return Card(
//                           color: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: ListTile(
//                             leading: CircleAvatar(
//                               backgroundImage: AssetImage(friend.profilePic),
//                             ),
//                             title: Text(friend.name),
//                             trailing: friend.upcomingEvents > 0
//                                 ? Container(
//                               padding: const EdgeInsets.all(6.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.purple[300],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 '${friend.upcomingEvents}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             )
//                                 : null,
//                             onTap: () {
//                               Navigator.pushNamed(context, '/giftList');
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Friend {
//   final String name;
//   final String profilePic;
//   final int upcomingEvents;
//
//   Friend({required this.name, required this.profilePic, required this.upcomingEvents});
// }

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
    List<Friend> friends = [
    Friend(name: 'Zeina Hesham', profilePic: 'assets/Zeina.jpg', upcomingEvents: 1),
    Friend(name: 'Gehad Mohamed', profilePic: 'assets/Gehad.jpg', upcomingEvents: 2),
    Friend(name: 'Farah Tharwat', profilePic: 'assets/Farah.jpg', upcomingEvents: 0),
  ];

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
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add,color: Colors.white,),
            onPressed: () {
             //ba3deen ha7ot list of events bta3thom
            },
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
          // Foreground content
            SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search friends\' gift lists...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // Search functionality logic here
                    },
                  ),
                  const SizedBox(height: 20),

                  // Create Event/List Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/createEvent');
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
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        Friend friend = friends[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(friend.profilePic),
                            ),
                            title: Text(friend.name),
                            trailing: friend.upcomingEvents > 0
                                ? Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.purple[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${friend.upcomingEvents}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                                : null,
                            onTap: () {
                              Navigator.pushNamed(context, '/giftList');
                            },
                          ),
                        );
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

class Friend {
  final String name;
  final String profilePic;
  final int upcomingEvents;

  Friend({required this.name, required this.profilePic, required this.upcomingEvents});
}
