import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/delivery_address.dart';
import 'package:models/local_user.dart';
import 'package:collection/collection.dart';

class UserRepo {
  static UserRepo? instance;
  static const _collectionUsers = "users";
  static const _collectionAddresses = "addresses";

  UserRepo._privateConstructor(this._restaurantsRepo, this._ordersRepo);

  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocalUser? _user;
  DeliveryAddress? _currentAddress;
  StreamSubscription? _addressesSubscription;
  final List<DeliveryAddress> _addresses = [];
  final StreamController<List<DeliveryAddress>> _addressesController =
      StreamController<List<DeliveryAddress>>.broadcast();

  factory UserRepo(RestaurantsRepo restaurantsRepo, OrdersRepo ordersRepo) {
    instance ??= UserRepo._privateConstructor(restaurantsRepo, ordersRepo);
    return instance!;
  }

  LocalUser? get user => _user;

  DeliveryAddress? get address => _currentAddress;

  List<DeliveryAddress> get addresses => _addresses;

  Stream<List<DeliveryAddress>> get addressesStream =>
      _addressesController.stream;

  getUser() async {
    try {
      final firebaseUser = await _firestore
          .collection(_collectionUsers)
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      final doc = firebaseUser.data()!;
      _user = LocalUser.fromMap(doc);
      _currentAddress = DeliveryAddress.fromMap(doc);
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

  Future<void> logout() async {
    await _stopSubscriptions();
    _user = null;
    _currentAddress = null;
    _addresses.clear();
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
      _currentAddress = null;
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.log("DELETE USER FAILED: $e");
    }
    return false;
  }

  _stopSubscriptions() async {
    await _addressesSubscription?.cancel();
    _addressesSubscription = null;
    await _restaurantsRepo.cancelAllRestaurantsSubscriptions();
    await _ordersRepo.stopListeningForOrderInProgress();
  }

  //region Address
  Future<bool> setDeliveryAddress(DeliveryAddress deliveryAddress) async {
    try {
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .update(deliveryAddress.toMap());

      _currentAddress = deliveryAddress;
      _addAddressToCollectionIfNeeded(deliveryAddress);
      return true;
    } on Exception catch (e) {
      debugPrint("Set address failed $e");
      return false;
    }
  }

  _addAddressToCollectionIfNeeded(DeliveryAddress address) {
    final collectionAddress = _getMatchingAddress(address);
    if (collectionAddress == null) {
      _addNewAddress(address);
    } else {
      print("address exists");
    }
  }

  DeliveryAddress? _getMatchingAddress(DeliveryAddress address) {
    return _addresses.firstWhereOrNull((e) =>
        e.street == address.street &&
        e.propertyDetails == address.propertyDetails);
  }

  Future<void> listenForAddresses() async {
    if (_addressesSubscription != null) {
      return;
    }
    _addressesSubscription = _firestore
        .collection(_collectionUsers)
        .doc(_auth.currentUser?.uid)
        .collection(_collectionAddresses)
        .snapshots()
        .listen((event) {
      if (event.docs.isEmpty) {
        _handleEmptyAddresses();
      } else {
        print("Got addresses ${event.docs.length}");
        _handleAddresses(event);
      }
    });
  }

  _handleEmptyAddresses() {
    if (_currentAddress != null) {
      // Add the current address to firebase addresses collection as home address
      final addressToAdd =
          _currentAddress!.copyWith(addressType: AddressType.home);

      print("Adding address ${addressToAdd.toMap()}");
      _addNewAddress(addressToAdd);
    }
  }

  void _addNewAddress(DeliveryAddress addressToAdd) {
    print("add new Address ${addressToAdd.toMap()}");
    _firestore
        .collection(_collectionUsers)
        .doc(_auth.currentUser?.uid)
        .collection(_collectionAddresses)
        .doc()
        .set(addressToAdd.toMap());
  }

  void _handleAddresses(QuerySnapshot<Map<String, dynamic>> event) {
    final addresses =
        event.docs.map((e) => DeliveryAddress.fromMap(e.data())).toList();
    _addresses.clear();
    _addresses.addAll(addresses);
    final matchingAddress = _getMatchingAddress(_currentAddress!);
    if (matchingAddress != null) {
      _currentAddress = matchingAddress;
    }
    _addressesController.add(List.from(_addresses));
  }
//endregion
}
