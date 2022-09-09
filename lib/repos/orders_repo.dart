import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:models/order_status.dart';
import 'package:models/user_order.dart';

class OrdersRepo {
  static const _collectionOrders = "orders";
  static const _collectionUsers = "users";

  OrdersRepo._privateConstructor();

  static OrdersRepo? _instance;

  factory OrdersRepo() {
    _instance ??= OrdersRepo._privateConstructor();
    return _instance!;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<UserOrder?> _currentOrderController =
      StreamController<UserOrder?>.broadcast();

  listenForOrderInProgress() {
    final query = _firestore
        .collection(_collectionUsers)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(_collectionOrders)
        .where("status", isNotEqualTo: OrderStatus.completed.toSimpleString());
    // query.get().then((value) {
    //   _handleChangedOrder(value);
    // });
    query.snapshots().listen((ordersSnapshot) {
      _handleChangedOrder(ordersSnapshot);
    });
  }

  void _handleChangedOrder(QuerySnapshot<Map<String, dynamic>> ordersSnapshot) {
    if (ordersSnapshot.docs.isNotEmpty) {
      final order = UserOrder.fromMap(ordersSnapshot.docs.first.data());
      _currentOrderController.add(order);
    } else {
      _currentOrderController.add(null);
    }
  }

  Stream<UserOrder?> get currentOrderStream => _currentOrderController.stream;
}
