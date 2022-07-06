import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepo {
  static UserRepo? instance;
  static const _collectionUsers = "users";

  UserRepo._privateConstructor();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  factory UserRepo() {
    instance ??= UserRepo._privateConstructor();
    return instance!;
  }

  Future<bool> isProfileCompleted() async {
    var firebaseUser = await _firestore.collection(_collectionUsers).doc(FirebaseAuth.instance.currentUser?.uid).get();
    var doc = firebaseUser.data()!;
    return doc["name"] != null;
  }
}
