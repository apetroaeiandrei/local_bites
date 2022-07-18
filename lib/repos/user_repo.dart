import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:models/local_user.dart';

class UserRepo {
  static UserRepo? instance;
  static const _collectionUsers = "users";

  UserRepo._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocalUser? _user;

  factory UserRepo() {
    instance ??= UserRepo._privateConstructor();
    return instance!;
  }

  LocalUser? get user => _user;

  Future<bool> isProfileCompleted() async {
    final firebaseUser = await _firestore
        .collection(_collectionUsers)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    final doc = firebaseUser.data()!;
    _user = LocalUser.fromMap(doc);
    return doc["name"] != null;
  }

  Future<bool> setUserDetails(
      String name, String phoneNumber) async {
    try {
      final properties = {
        "email": _auth.currentUser?.email,
        "name": name,
        "uid": _auth.currentUser?.uid,
        "phoneNumber": phoneNumber,
      };
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .set(properties);
      _user = LocalUser.fromMap(properties);
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }
}
