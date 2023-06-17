import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/delivery_address.dart';
import 'package:models/feedback_model.dart';
import 'package:models/local_user.dart';
import 'package:collection/collection.dart';
import 'package:models/user_order.dart';
import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_factory.dart';

class UserRepo {
  static UserRepo? instance;
  static const _collectionUsers = "users";
  static const _collectionAddresses = "addresses";
  static const _collectionRestaurants = "restaurants";
  static const _collectionFeedback = "feedback";
  static const _collectionVouchers = "vouchers";

  UserRepo._privateConstructor(this._restaurantsRepo, this._ordersRepo);

  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LocalUser? _user;
  DeliveryAddress? _currentAddress;
  StreamSubscription? _addressesSubscription;
  StreamSubscription? _vouchersSubscription;
  final List<DeliveryAddress> _addresses = [];
  final List<Voucher> _vouchers = [];
  final StreamController<List<Voucher>> _vouchersController =
      StreamController<List<Voucher>>.broadcast();
  final StreamController<List<DeliveryAddress>> _addressesController =
      StreamController<List<DeliveryAddress>>.broadcast();

  factory UserRepo(RestaurantsRepo restaurantsRepo, OrdersRepo ordersRepo) {
    instance ??= UserRepo._privateConstructor(restaurantsRepo, ordersRepo);
    return instance!;
  }

  LocalUser? get user => _user;

  DeliveryAddress? get address => _currentAddress;

  List<DeliveryAddress> get addresses => _addresses;

  List<Voucher> get vouchers => _vouchers;

  Stream<List<DeliveryAddress>> get addressesStream =>
      _addressesController.stream;

  Stream<List<Voucher>> get vouchersStream => _vouchersController.stream;

  getUser() async {
    try {
      final firebaseUser = await _firestore
          .collection(_collectionUsers)
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      final doc = firebaseUser.data()!;
      _user = LocalUser.fromMap(doc);
      _currentAddress = DeliveryAddress.fromMap(doc);
      await _listenForVouchers();
      Analytics().setUserId(_user!.uid);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  Future<bool> isProfileCompleted() async {
    bool isCompleted =
        user != null && user!.phoneNumber.isNotEmpty && user!.name.isNotEmpty;
    return isCompleted;
  }

  Future<bool> setUserDetails(String name, {String? phoneNumber}) async {
    try {
      final properties = {
        "email":
            _auth.currentUser?.email ?? "anonymous ${_auth.currentUser?.uid}",
        "name": name,
        "uid": _auth.currentUser?.uid,
      };
      if (phoneNumber != null) {
        properties["phoneNumber"] = phoneNumber;
      }
      await _firestore
          .collection(_collectionUsers)
          .doc(_auth.currentUser?.uid)
          .update(properties);
      _user = LocalUser.fromMap(properties);
      return true;
    } on Exception catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    await _stopSubscriptions();
    _user = null;
    _currentAddress = null;
    _addresses.clear();
    _vouchers.clear();
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
    } catch (error) {
      FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
    }
    return false;
  }

  _stopSubscriptions() async {
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

  _listenForVouchers() {
    _vouchersSubscription = _firestore
        .collection(_collectionUsers)
        .doc(_auth.currentUser?.uid)
        .collection(_collectionVouchers)
        .where("isUsed", isEqualTo: false)
        .snapshots()
        .listen((event) {
      print("Vouchers changed ${event.docs.length}");
      _vouchers.clear();
      _vouchers.addAll(
          event.docs.map((e) => VoucherFactory.parse(e.data())).toList());
      _vouchersController.add(List.from(_vouchers));
    });
  }
}
