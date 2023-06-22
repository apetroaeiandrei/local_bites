import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_config.dart';
import 'package:models/vouchers/voucher_factory.dart';

import '../navigation_service.dart';
import 'notifications_repo.dart';

class VouchersRepo {
  static const _collectionUsers = "users";
  static const _collectionVouchers = "vouchers";
  static const _collectionVouchersConfig = "vouchers";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static VouchersRepo? _instance;

  VouchersRepo._privateConstructor(this._notificationsRepo);

  factory VouchersRepo(NotificationsRepo notificationsRepo) {
    _instance ??= VouchersRepo._privateConstructor(notificationsRepo);
    return _instance!;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsRepo _notificationsRepo;
  final List<Voucher> _vouchers = [];
  final List<VoucherConfig> _vouchersConfig = [];

  final StreamController<List<Voucher>> _vouchersController =
      StreamController<List<Voucher>>.broadcast();
  StreamSubscription? _vouchersSubscription;

  List<Voucher> get vouchers => _vouchers;

  List<VoucherConfig> get vouchersConfig => _vouchersConfig;

  Stream<List<Voucher>> get vouchersStream => _vouchersController.stream;

  listenForVouchers() async {
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

  getVouchersConfig() async {
    final docsSnap =
        await _firestore.collection(_collectionVouchersConfig).get();
    final vouchersConfigDocs =
        docsSnap.docs.map((e) => VoucherConfig.fromMap(e.data())).toList();
    _vouchersConfig.clear();
    _vouchersConfig.addAll(vouchersConfigDocs);
  }

  void scheduleVoucherNotifications(List<Voucher> vouchers) {
    final BuildContext context = NavigationService.navigatorKey.currentContext!;
    for (var voucher in vouchers) {
      final expiryIntervalDays =
          voucher.expiryDate.difference(DateTime.now()).inDays;
    }
  }
}
