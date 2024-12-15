import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_conn.dart';

class SignInController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final MyDatabaseClass _dbHelper = MyDatabaseClass();

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
      return 'An error occurred: $e';
    }
  }
}