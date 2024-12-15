// import 'package:flutter/material.dart';
// import 'Views/signup_view.dart';
// import 'main.dart';
//
// class SignInPage extends StatelessWidget {
//   const SignInPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   // Color(0xFFE9C8B7),
//                   Color(0xFFFFA07A),
//                   Color(0xFF749CE0),
//                   Color(0xFF9575AE),
//                 ],
//               ),
//             ),
//           ),
//           // Sign-in form content
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     "Welcome Back!",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Email field
//                   TextField(
//                     style: TextStyle(color: Colors.grey[800]),
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white,
//                       hintText: 'Gmail',
//                       hintStyle: TextStyle(color: Colors.orange[300]),
//                       prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Password field
//                   TextField(
//                     style: TextStyle(color: Colors.grey[800]),
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white,
//                       hintText: 'Password',
//                       hintStyle: TextStyle(color: Colors.orange[300]),
//                       prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
//                       suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   // Forgot password link
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () {
//                         // Add navigation for forgot password
//                       },
//                       child: const Text(
//                         "Forgot password?",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Sign-in button
//                   ElevatedButton(
//                     onPressed: () {
//                       // Add sign-in logic
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const MainScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 50,
//                         vertical: 15,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: const Text(
//                       "SIGN IN",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Sign-up link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         "Don’t have an account?",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const SignUpPage()),
//                           );
//                         },
//                         child: const Text(
//                           "Sign up",
//                           style: TextStyle(
//                             color: Colors.orange,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
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
//
