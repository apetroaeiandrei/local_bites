import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/delivery_address.dart';
import 'package:models/feedback_model.dart';
import 'package:models/local_user.dart';
import 'package:collection/collection.dart';
import 'package:models/user_order.dart';
import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_config.dart';
import 'package:models/vouchers/voucher_factory.dart';

class UserRepo {
  static UserRepo? instance;
  static const _collectionUsers = "users";
  static const _collectionAddresses = "addresses";
  static const _collectionRestaurants = "restaurants";
  static const _collectionFeedback = "feedback";
  static const _collectionVouchers = "vouchers";
  static const _collectionVouchersConfig = "vouchers";

  UserRepo._privateConstructor(this._restaurantsRepo, this._ordersRepo);

  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocalUser? _user;
  DeliveryAddress? _currentAddress;
  StreamSubscription? _addressesSubscription;
  StreamSubscription? _vouchersSubscription;
  StreamSubscription? _userSubscription;
  final List<DeliveryAddress> _addresses = [];
  final List<Voucher> _vouchers = [];
  final List<VoucherConfig> _vouchersConfig = [];

  final StreamController<List<Voucher>> _vouchersController =
      StreamController<List<Voucher>>.broadcast();
  final StreamController<List<DeliveryAddress>> _addressesController =
      StreamController<List<DeliveryAddress>>.broadcast();
  final StreamController<LocalUser> _userController =
      StreamController<LocalUser>.broadcast();

  factory UserRepo(RestaurantsRepo restaurantsRepo, OrdersRepo ordersRepo) {
    instance ??= UserRepo._privateConstructor(restaurantsRepo, ordersRepo);
    return instance!;
  }

  LocalUser? get user => _user;

  DeliveryAddress? get address => _currentAddress;

  List<DeliveryAddress> get addresses => _addresses;

  List<Voucher> get vouchers => _vouchers;

  List<VoucherConfig> get vouchersConfig => _vouchersConfig;

  Stream<List<DeliveryAddress>> get addressesStream =>
      _addressesController.stream;

  Stream<List<Voucher>> get vouchersStream => _vouchersController.stream;

  Stream<LocalUser> get userStream => _userController.stream;

  getUser() async {
    final userSnap = await _firestore
        .collection(_collectionUsers)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    final doc = userSnap.data()!;
    _handleUserChanged(doc);
    await _listenForVouchers();
    Analytics().setUserId(_user!.uid);
    _listenForUserChanges();
    _getVouchersConfig();
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
      {String? name, String? phoneNumber, bool? phoneVerified, String? referredBy}) async {
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
    _vouchers.clear();
  }

  Future<bool> deleteUser() async {
    try {
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .delete();
      await _auth.currentUser?.delete();
      onLogout();
      return true;
    } catch (error) {
      FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
    }
    return false;
  }

  _stopSubscriptions() async {
    await _userSubscription?.cancel();
    await _addressesSubscription?.cancel();
    _addressesSubscription = null;
    await _restaurantsRepo.cancelAllRestaurantsSubscriptions();
    await _ordersRepo.stopListeningForOrderInProgress();
    await _vouchersSubscription?.cancel();
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

  Future<bool> sendFeedback(UserOrder userOrder, String feedback,
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

  _listenForVouchers() async {
    await _vouchersSubscription?.cancel();
    _vouchersSubscription = _firestore
        .collection(_collectionUsers)
        .doc(_auth.currentUser?.uid)
        .collection(_collectionVouchers)
        .where("isUsed", isEqualTo: false)
        .snapshots()
        .listen((event) {
      final newVouchers =
          event.docs.map((e) => VoucherFactory.parse(e.data())).toList();
      _vouchers.clear();
      _vouchers.addAll(newVouchers);
      _vouchersController.add(List.from(newVouchers));
    });
  }

  _getVouchersConfig() async {
    final docsSnap =
        await _firestore.collection(_collectionVouchersConfig).get();
    final vouchersConfigDocs =
        docsSnap.docs.map((e) => VoucherConfig.fromMap(e.data())).toList();
    _vouchersConfig.clear();
    _vouchersConfig.addAll(vouchersConfigDocs);
  }
}
