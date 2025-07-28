import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get currentUser => FirebaseAuth.instance.currentUser;
  static Future<User?> signIn(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return userCred.user;
  }

  static Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String dob,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'dob': dob,
          'createdAt': Timestamp.now(),
          'uid': user.uid,
        });
      }

      return user;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }


  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
