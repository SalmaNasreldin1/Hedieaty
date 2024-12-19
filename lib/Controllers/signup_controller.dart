import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_conn.dart';


class SignUpController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final MyDatabaseClass _dbHelper = MyDatabaseClass();

  Future<String> signUp(String name, String email, String password, String mobile) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || mobile.isEmpty) {
      return 'All fields are required.';
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
      return 'Invalid email format.';
    }

    if (password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[!@#\\$&*~]').hasMatch(password)) {
      return 'Password must be strong (8 characters, uppercase, lowercase, number, special character).';
    }

    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('Users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'mobile': mobile.trim(),
        'preferences': '',
      });

      final db = await _dbHelper.mydbcheck();
      await db!.insert('Users', {
        'uid': uid,
        'name': name,
        'email': email,
        'mobile': mobile,
        'preferences': '',
      });

      return 'success';
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return 'Email is already in use.';
        } else if (e.code == 'weak-password') {
          return 'The password is too weak.';
        } else if (e.code == 'invalid-email') {
          return 'The email is not valid.';
        }
      }
      return 'An unknown error occurred: $e';
    }
  }
}