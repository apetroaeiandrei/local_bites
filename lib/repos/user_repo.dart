import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/delivery_address.dart';
import 'package:models/local_user.dart';

class UserRepo {
  static UserRepo? instance;
  static const _collectionUsers = "users";

  UserRepo._privateConstructor(this._restaurantsRepo, this._ordersRepo);

  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocalUser? _user;
  DeliveryAddress? _address;

  factory UserRepo(RestaurantsRepo restaurantsRepo, OrdersRepo ordersRepo) {
    instance ??= UserRepo._privateConstructor(restaurantsRepo, ordersRepo);
    return instance!;
  }

  LocalUser? get user => _user;

  DeliveryAddress? get address => _address;

  getUser() async {
    try {
      final firebaseUser = await _firestore
          .collection(_collectionUsers)
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      final doc = firebaseUser.data()!;
      _user = LocalUser.fromMap(doc);
      _address = DeliveryAddress.fromMap(doc);
      Analytics().setUserId(_user!.uid);
    } catch (e) {
      //No-op
    }
  }

  Future<bool> isProfileCompleted() async {
    bool isCompleted = user != null;
    return isCompleted;
  }

  Future<bool> setUserDetails(String name, String phoneNumber) async {
    try {
      final properties = {
        "email":
            _auth.currentUser?.email ?? "anonymous ${_auth.currentUser?.uid}",
        "name": name,
        "uid": _auth.currentUser?.uid,
        "phoneNumber": phoneNumber,
      };
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .update(properties);
      _user = LocalUser.fromMap(properties);
      return true;
    } on Exception catch (e) {
      debugPrint("Auth failed $e");
      return false;
    }
  }

  Future<bool> setDeliveryAddress(double latitude, double longitude,
      String street, String propertyDetails) async {
    try {
      final properties = {
        "latitude": latitude,
        "longitude": longitude,
        "street": street,
        "propertyDetails": propertyDetails,
      };
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .update(properties);

      _address = DeliveryAddress.fromMap(properties);
      return true;
    } on Exception catch (e) {
      debugPrint("Set address failed $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _stopSubscriptions();
    _user = null;
    _address = null;
  }

  Future<bool> deleteUser() async {
    try {
      await _stopSubscriptions();
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .delete();
      await _auth.currentUser?.delete();
      _user = null;
      _address = null;
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.log("DELETE USER FAILED: $e");
    }
    return false;
  }

  _stopSubscriptions() async {
    await _restaurantsRepo.cancelAllRestaurantsSubscriptions();
    await _ordersRepo.stopListeningForOrderInProgress();
  }
}
