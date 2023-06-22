import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_config.dart';
import 'package:models/vouchers/voucher_factory.dart';

import '../generated/l10n.dart';
import '../navigation_service.dart';
import 'notifications_repo.dart';

class VouchersRepo {
  static const _collectionUsers = "users";
  static const _collectionVouchers = "vouchers";
  static const _collectionVouchersConfig = "vouchers";
  static const int _voucherSoonExpiringDays = 4;
  static const int _voucherNotificationDeliveryHour = 10;
  static const int _voucherNotificationDeliveryMinute = 23;
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

  onLogout() async {
    _vouchers.clear();
    await _vouchersSubscription?.cancel();
  }

  listenForVouchers() async {
    await _vouchersSubscription?.cancel();
    _vouchersSubscription = _firestore
        .collection(_collectionUsers)
        .doc(_auth.currentUser?.uid)
        .collection(_collectionVouchers)
        .where("isUsed", isEqualTo: false)
        .snapshots()
        .listen((event) async {
      final newVouchers =
          event.docs.map((e) => VoucherFactory.parse(e.data())).toList();
      _vouchers.clear();
      _vouchers.addAll(newVouchers);
      _vouchersController.add(List.from(newVouchers));
      await _handleVouchersNotificationsAndExpiration(_vouchers);
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

  // ignore_for_file: use_build_context_synchronously
  Future<void> _handleVouchersNotificationsAndExpiration(
      List<Voucher> vouchers) async {
    final BuildContext context = NavigationService.navigatorKey.currentContext!;
    // Sort vouchers by expiry date
    vouchers.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    DateTime now = DateTime.now();
    List<Voucher> soonExpiringVouchers = [];
    List<Voucher> expiredVouchers = [];

    await _notificationsRepo.clearAllVoucherScheduledNotifications();

    for (int i = 0; i < vouchers.length; i++) {
      DateTime expiryDate = DateTime(
          vouchers[i].expiryDate.year,
          vouchers[i].expiryDate.month,
          vouchers[i].expiryDate.day,
          _voucherNotificationDeliveryHour,
          _voucherNotificationDeliveryMinute);
      DateTime expiryTomorrow = expiryDate.subtract(const Duration(days: 1));
      DateTime expirySoon =
          expiryDate.subtract(const Duration(days: _voucherSoonExpiringDays));

      if (vouchers[i].expiryDate.isBefore(now)) {
        expiredVouchers.add(vouchers[i]);
      }

      // Multiple vouchers expiring soon
      if (expirySoon.isAfter(now)) {
        soonExpiringVouchers.add(vouchers[i]);
      }

      if (expiryTomorrow.isAfter(now)) {
        // Voucher expiring tomorrow
        await _notificationsRepo.scheduleVoucherNotifications(
          title: S.of(context).voucher_notification_reminder_title,
          body: S.of(context).voucher_notification_reminder_tomorrow_body,
          notificationDate: expiryTomorrow,
        );
      }

      if (expiryDate.isAfter(now)) {
        // Voucher expiring today
        await _notificationsRepo.scheduleVoucherNotifications(
          title: S.of(context).voucher_notification_reminder_title,
          body: S.of(context).voucher_notification_reminder_today_body,
          notificationDate: expiryDate,
        );
      }
    }

    if (soonExpiringVouchers.length > 1) {
      // Schedule notification for multiple soon expiring vouchers
      await _notificationsRepo.scheduleVoucherNotifications(
        title: S.of(context).voucher_notification_reminder_title,
        body: S.of(context).voucher_notification_reminder_soon_body,
        notificationDate: soonExpiringVouchers.first.expiryDate
            .subtract(const Duration(days: 3)),
      );
    }

    if (expiredVouchers.isNotEmpty) {
      //mark vouchers as used in firebase in  batch write
      WriteBatch batch = _firestore.batch();
      for (int i = 0; i < expiredVouchers.length; i++) {
        DocumentReference docRef = _firestore
            .collection(_collectionUsers)
            .doc(_auth.currentUser?.uid)
            .collection(_collectionVouchers)
            .doc(expiredVouchers[i].id);
        batch.update(docRef, {'isUsed': true});
      }
      await batch.commit();
    }
  }
}
