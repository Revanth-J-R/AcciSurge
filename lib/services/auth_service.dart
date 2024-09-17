// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a new user
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String residentialAddress,
    required String officeAddress,
    required String password,
    String? deviceToken, // New deviceToken parameter
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Save additional user info to Firestore, including the deviceToken
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'residentialAddress': residentialAddress,
        'officeAddress': officeAddress,
        'deviceToken': deviceToken, // Store the device token
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Login existing user
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
