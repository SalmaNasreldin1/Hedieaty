// import 'package:flutter/material.dart';
// import 'HomePage.dart';
// import 'GiftListPage.dart';
// import 'EventListPage.dart';
// import 'GiftDetailsPage.dart';
// import 'ProfilePage.dart';
// import 'MyPledgedGiftsPage.dart';
//
// void main() {
//   runApp(const HedieatyApp());
// }
//
// class HedieatyApp extends StatelessWidget {
//   const HedieatyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Hedieaty',
//       theme: ThemeData(
//         primaryColor: Colors.purple,
//         primarySwatch: Colors.deepPurple,
//         scaffoldBackgroundColor: Colors.grey[50],
//         hintColor: Colors.orange.shade300,
//         textTheme: TextTheme(
//           titleLarge: TextStyle(color: Colors.grey[900]), // For dark grey text
//           bodyLarge: TextStyle(color: Colors.grey[800]),
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.purple,
//           titleTextStyle: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//            ),
//         ),
//         bottomNavigationBarTheme: BottomNavigationBarThemeData(
//           backgroundColor: Colors.purple,
//           selectedItemColor: Colors.orange.shade300,
//           unselectedItemColor: Colors.purple.shade200,
//         ),
//       ),
//       home: const MainScreen(),
//     );
//   }
// }
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _pages = [
//     HomePage(),
//     EventListPage(),
//     MyPledgedGiftsPage(),
//     ProfilePage(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.event),
//             label: 'Events',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.card_giftcard),
//             label: 'Pledged Gifts',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'Views/home_page_view.dart';
import 'Views/profile_view.dart';
import 'package:hedieaty/Views/pledged_gifts_view.dart';
import 'Views/signin_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Views/my_event_list_view.dart';
import 'Controllers/signin_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const HedieatyApp());
}

class HedieatyApp extends StatelessWidget {
  const HedieatyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primaryColor: Colors.purple[200], // Softer purple
        scaffoldBackgroundColor: Colors.grey[50],
        hintColor: Colors.orange[300],
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Colors.grey[800]),
          bodyLarge: TextStyle(color: Colors.grey[700]),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.purple[300],
          selectedItemColor: Colors.deepOrange[200],
          unselectedItemColor: Colors.purple[300],
        ),
      ),
      // home: const MainScreen(),
      home: const SignInPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final SignInController signInController = SignInController();
  String? uid ;

  // final List<Widget> _pages = [
  //   HomePage(),
  //   EventListPage(),
  //   MyPledgedGiftsPage(uid: uid),
  //   ProfilePage(),
  // ];

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializeUID();
  }

  Future<void> _initializeUID() async {
    uid = await signInController.getUserUID();
    setState(() {
      _pages.addAll([
        HomePage(),
        EventListPage(),
        PledgedGiftsPage( userId: uid!), // Pass the UID here
        ProfilePage(),
      ]);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Future<String?> getUID()async => await signInController.getUserUID();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Pledged Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
