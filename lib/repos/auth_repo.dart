import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  static AuthRepo? instance;
  static const String _collectionUsers = "users";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthRepo._privateConstructor();

  factory AuthRepo() {
    instance ??= AuthRepo._privateConstructor();
    return instance!;
  }

  Future<bool> isLoggedIn() async {
    var firebaseUser = _auth.currentUser;
    firebaseUser ??= await _auth.authStateChanges().first;
    return firebaseUser != null;
  }

  String? get uid => _auth.currentUser?.uid;

  Future<bool> register(String email, String password) async {
    try {
      final user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection(_collectionUsers).doc(user.user?.uid).set({
        "email": email,
        "uid": user.user?.uid,
      });
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> loginAnonymously() async {
    try {
      final user = await _auth.signInAnonymously();
      await _firestore.collection(_collectionUsers).doc(user.user?.uid).set({
        "email": "anonymous ${user.user?.uid}",
        "uid": user.user?.uid,
      });
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }
}
