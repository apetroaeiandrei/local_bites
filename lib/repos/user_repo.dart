import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/delivery_address.dart';
import 'package:models/delivery_prices.dart';
import 'package:models/feedback_model.dart';
import 'package:models/local_user.dart';
import 'package:collection/collection.dart';
import 'package:models/no_go_zone.dart';
import 'package:models/user_order.dart';

import '../constants.dart';

class UserRepo {
  static UserRepo? instance;
  static const _collectionUsers = "users";
  static const _collectionAdminUsers = "admin_users";
  static const _collectionAddresses = "addresses";
  static const _collectionRestaurants = "restaurants";
  static const _collectionFeedback = "feedback";
  static const _collectionCouriers = "couriers";
  static const _collectionNoGoZones = "noGoZones";

  UserRepo._privateConstructor(
    this._restaurantsRepo,
    this._ordersRepo,
  );

  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocalUser? _user;
  String _currentZipCode = "";
  DeliveryPrices _deliveryPrices = DefaultDeliveryPrices();
  DeliveryAddress? _currentAddress;
  StreamSubscription? _addressesSubscription;
  StreamSubscription? _userSubscription;
  StreamSubscription? _deliveryPricesSubscription;
  StreamSubscription? _noGoZonesSubscription;
  bool _isInNoGoZone = false;
  final List<DeliveryAddress> _addresses = [];

  final StreamController<List<DeliveryAddress>> _addressesController =
      StreamController<List<DeliveryAddress>>.broadcast();
  final StreamController<LocalUser> _userController =
      StreamController<LocalUser>.broadcast();
  final StreamController<DeliveryPrices> _deliveryPricesController =
      StreamController<DeliveryPrices>.broadcast();
  final StreamController<bool> _isInNoGoZoneController =
      StreamController<bool>.broadcast();

  factory UserRepo(
    RestaurantsRepo restaurantsRepo,
    OrdersRepo ordersRepo,
  ) {
    instance ??= UserRepo._privateConstructor(
      restaurantsRepo,
      ordersRepo,
    );
    return instance!;
  }

  bool get isInNoGoZone => _isInNoGoZone;

  LocalUser? get user => _user;

  DeliveryAddress? get address => _currentAddress;

  DeliveryPrices get deliveryPrices => _deliveryPrices;

  List<DeliveryAddress> get addresses => _addresses;

  Stream<List<DeliveryAddress>> get addressesStream =>
      _addressesController.stream;

  Stream<LocalUser> get userStream => _userController.stream;

  //todo check why unused
  Stream<DeliveryPrices> get deliveryPricesStream =>
      _deliveryPricesController.stream;

  Stream<bool> get isInNoGoZoneStream => _isInNoGoZoneController.stream;

  getUser() async {
    final userSnap = await _firestore
        .collection(_collectionUsers)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    final doc = userSnap.data()!;
    _handleUserChanged(doc);
    Analytics().setUserId(_user!.uid);
    _listenForUserChanges();
  }

  _listenForUserChanges() {
    try {
      _userSubscription = _firestore
          .collection(_collectionUsers)
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots()
          .listen((event) async {
        final doc = event.data()!;
        _handleUserChanged(doc);
      });
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  _handleUserChanged(Map<String, dynamic> doc) {
    _user = LocalUser.fromMap(doc);
    _setUserReferralCodeIfNeeded();
    _tryToParseAddress(doc);
    _userController.add(_user!);
    _listenForDeliveryPrices(_user!.zipCode ?? Constants.fallbackZipCode);
    if (user?.zipCode != null) {
      _listenForNoGoZones(_user!.zipCode!);
    }
  }

  _setUserReferralCodeIfNeeded() async {
    if (_user != null && _user!.referralCode.isEmpty) {
      await _firestore.collection(_collectionUsers).doc(_user!.uid).update({
        "referralCode": _getUserReferralCode(_user!.uid),
      });
    }
  }

  _tryToParseAddress(Map<String, dynamic> doc) {
    try {
      _currentAddress = DeliveryAddress.fromMap(doc);
    } catch (e) {
      debugPrint("Error parsing address");
    }
  }

  String _getUserReferralCode(String uid) {
    return uid.substring(0, 6).toUpperCase();
  }

  bool isProfileCompleted() {
    bool isCompleted =
        user != null && user!.phoneNumber.isNotEmpty && user!.name.isNotEmpty;
    return isCompleted;
  }

  Future<bool> createOrUpdateUser(String userId, String phoneNumber) async {
    try {
      final userDoc =
          await _firestore.collection(_collectionUsers).doc(userId).get();
      if (!userDoc.exists) {
        await createUser(
          phoneNumber: phoneNumber,
          phoneVerified: true,
        );
      } else {
        await updateUserDetails(
          phoneNumber: phoneNumber,
          phoneVerified: true,
        );
      }
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
    return true;
  }

  Future<void> createUser({
    String? name,
    String? phoneNumber,
    required bool phoneVerified,
  }) async {
    String email = "";
    if (_auth.currentUser?.email != null) {
      email = _auth.currentUser!.email ?? "";
    } else if (_auth.currentUser?.phoneNumber != null) {
      email = _auth.currentUser!.phoneNumber ?? "";
    } else {
      email = "anonymous ${_auth.currentUser?.uid}";
    }

    try {
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .set({
        "email": email,
        "uid": _auth.currentUser?.uid,
        "name": name,
        "phoneNumber": phoneNumber,
        "phoneVerified": phoneVerified,
        "referralCode": _getUserReferralCode(_auth.currentUser?.uid ?? ""),
      });
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  Future<bool> updateUserDetails(
      {String? name,
      String? phoneNumber,
      bool? phoneVerified,
      String? referredBy,
      String? fcmToken}) async {
    try {
      final properties = <String, dynamic>{};
      if (name != null) {
        properties["name"] = name;
      }
      if (phoneNumber != null) {
        properties["phoneNumber"] = phoneNumber;
      }
      if (phoneVerified != null) {
        properties["phoneVerified"] = phoneVerified;
      }
      if (referredBy != null) {
        properties["referredBy"] = referredBy;
      }
      if (fcmToken != null) {
        properties["fcmToken"] = fcmToken;
      }

      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .update(properties);
      return true;
    } on Exception catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> onLogout() async {
    await _stopSubscriptions();
    _user = null;
    _currentAddress = null;
    _addresses.clear();
  }

  _stopSubscriptions() async {
    await _userSubscription?.cancel();
    await _addressesSubscription?.cancel();
    await _deliveryPricesSubscription?.cancel();
    await _noGoZonesSubscription?.cancel();
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
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  _addAddressToCollectionIfNeeded(DeliveryAddress address) {
    final collectionAddress = _getMatchingAddress(address);
    if (collectionAddress == null) {
      _addNewAddress(address);
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
        _handleAddresses(event);
      }
    });
  }

  _handleEmptyAddresses() {
    if (_currentAddress != null) {
      // Add the current address to firebase addresses collection as home address
      final addressToAdd =
          _currentAddress!.copyWith(addressType: AddressType.home);
      _addNewAddress(addressToAdd);
    }
  }

  void _addNewAddress(DeliveryAddress addressToAdd) {
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

  void deleteAddress(DeliveryAddress address) {
    _firestore
        .collection(_collectionUsers)
        .doc(_auth.currentUser?.uid)
        .collection(_collectionAddresses)
        .where("street", isEqualTo: address.street)
        .where("propertyDetails", isEqualTo: address.propertyDetails)
        .get()
        .then((value) {
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
  }

  //endregion

  Future<bool> sendRestaurantFeedback(UserOrder userOrder, String feedback,
      bool isPositive, List<FeedbackSuggestions> suggestions) async {
    final restaurantDoc = _firestore
        .collection(_collectionRestaurants)
        .doc(userOrder.restaurantId);
    if (isPositive) {
      restaurantDoc.update({
        "feedbackPositive": FieldValue.increment(1),
      });
    } else {
      restaurantDoc.update({
        "feedbackNegative": FieldValue.increment(1),
      });
    }
    final doc = restaurantDoc.collection(_collectionFeedback).doc();
    final FeedbackModel feedbackModel = FeedbackModel(
      id: doc.id,
      comment: feedback,
      isPositive: isPositive,
      orderId: userOrder.orderId,
      userName: _user!.name,
      userPhone: _user!.phoneNumber,
      orderDate: userOrder.date,
      seen: false,
      suggestions: suggestions,
    );
    try {
      await doc.set(feedbackModel.toMap());
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> sendCourierFeedback(UserOrder userOrder, String feedback,
      bool isPositive, List<FeedbackSuggestions> suggestions) async {
    final courierDoc =
        _firestore.collection(_collectionAdminUsers).doc(userOrder.courierId);

    if (isPositive) {
      courierDoc.update({
        "feedbackPositive": FieldValue.increment(1),
      });
    } else {
      courierDoc.update({
        "feedbackNegative": FieldValue.increment(1),
      });
    }
    final doc = courierDoc.collection(_collectionFeedback).doc();
    final FeedbackModel feedbackModel = FeedbackModel(
      id: doc.id,
      comment: feedback,
      isPositive: isPositive,
      orderId: userOrder.orderId,
      userName: _user!.name,
      userPhone: _user!.phoneNumber,
      orderDate: userOrder.date,
      seen: false,
      suggestions: suggestions,
    );
    try {
      await doc.set(feedbackModel.toMap());
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> setUserZipCode(String s) async {
    await _firestore
        .collection(_collectionUsers)
        .doc(_auth.currentUser?.uid)
        .update({"zipCode": s});
  }

  _listenForDeliveryPrices(String zipCode) async {
    if (_currentZipCode == zipCode) {
      return;
    }
    _currentZipCode = zipCode;
    await _deliveryPricesSubscription?.cancel();
    _deliveryPricesSubscription = _firestore
        .collection(_collectionCouriers)
        .doc(zipCode)
        .snapshots()
        .listen((event) {
      if (event.exists) {
        final prices = DeliveryPrices.fromMap(event.data()!);
        _deliveryPricesController.add(prices);
        _deliveryPrices = prices;
      }
    });
  }

  Future<void> _listenForNoGoZones(String zipCode) async {
    await _noGoZonesSubscription?.cancel();
    _noGoZonesSubscription = _firestore
        .collection(_collectionCouriers)
        .doc(zipCode)
        .collection(_collectionNoGoZones)
        .where("active", isEqualTo: true)
        .snapshots()
        .listen((event) {
      final zones = event.docs.map((e) => NoGoZone.fromMap(e.data())).toList();
      for (var zone in zones) {
        final distance = zone.location
            .distance(lat: address!.latitude, lng: address!.longitude);
        if (distance <= zone.radius) {
          _isInNoGoZone = true;
          _isInNoGoZoneController.add(true);
          return;
        }
      }
      _isInNoGoZone = false;
      _isInNoGoZoneController.add(false);
    });
  }
}
