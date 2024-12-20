import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database_conn.dart';

class SignInController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final MyDatabaseClass _dbHelper = MyDatabaseClass();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and Password are required.';
    }

    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Save the UID securely
      await _secureStorage.write(key: 'userUID', value: uid);

      final db = await _dbHelper.mydbcheck();
      List<Map<String, dynamic>> existingUsers = await db!.query(
        'Users',
        where: 'uid = ?',
        whereArgs: [uid],
      );

      if (existingUsers.isEmpty) {
        DocumentSnapshot userDoc = await _firestore.collection('Users').doc(uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          userData.remove('friends');
          await db.insert('Users', userData);
        }
      }

      return 'success';
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          return 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          return 'Wrong password provided.';
        }
      }
      print(e);
      return 'An error occurred: $e';
    }
  }

  Future<String?> getUserUID() async {
    return await _secureStorage.read(key: 'userUID');
  }

  Future<String?> fetchUserName(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['name'] as String?; // Safely cast to String
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
    return null; // Return null if name couldn't be fetched
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _secureStorage.deleteAll(); // Clear stored session data
  }

}
