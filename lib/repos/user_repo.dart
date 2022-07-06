import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserRepo {
  static UserRepo? instance;
  static const _collectionUsers = "users";

  UserRepo._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory UserRepo() {
    instance ??= UserRepo._privateConstructor();
    return instance!;
  }

  Future<bool> isProfileCompleted() async {
    final firebaseUser = await _firestore
        .collection(_collectionUsers)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    final doc = firebaseUser.data()!;
    return doc["name"] != null;
  }

  Future<bool> setUserDetails(
      String name, String address, String phoneNumber) async {
    try {
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .set({
        "email": _auth.currentUser?.email,
        "name": name,
        "uid": _auth.currentUser?.uid,
        "address": address,
        "phoneNumber": phoneNumber,
      });
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }
}
