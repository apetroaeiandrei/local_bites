import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:models/order.dart';
import 'package:models/order_status.dart';
import 'package:models/user_order.dart';

class OrdersRepo {
  static const _collectionOrders = "orders";
  static const _collectionUsers = "users";
  static const _collectionRestaurants = "restaurants";

  OrdersRepo._privateConstructor();

  static OrdersRepo? _instance;

  factory OrdersRepo() {
    _instance ??= OrdersRepo._privateConstructor();
    return _instance!;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<UserOrder>> _currentOrderController =
      StreamController<List<UserOrder>>.broadcast();

  listenForOrderInProgress() {
    final query = _firestore
        .collection(_collectionUsers)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(_collectionOrders)
        .where("status", isNotEqualTo: OrderStatus.completed.toSimpleString());
    query.snapshots().listen((ordersSnapshot) {
      _handleChangedOrder(ordersSnapshot);
    });
  }

  void _handleChangedOrder(QuerySnapshot<Map<String, dynamic>> ordersSnapshot) {
    final orders =
        ordersSnapshot.docs.map((e) => UserOrder.fromMap(e.data())).toList();
    _currentOrderController.add(orders);
  }

  Stream<List<UserOrder>> get currentOrderStream =>
      _currentOrderController.stream;

  Future<Order> getOrder(String orderId, String restaurantId) async {
    final orderSnapshot = await _firestore
        .collection(_collectionRestaurants)
        .doc(restaurantId)
        .collection(_collectionOrders)
        .doc(orderId)
        .get();
    return Order.fromMap(orderSnapshot.data()!);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getOrderSnapshotsStream(
      String restaurantId, String orderId) {
    return _firestore
        .collection(_collectionRestaurants)
        .doc(restaurantId)
        .collection(_collectionOrders)
        .doc(orderId)
        .snapshots();
  }

  Future<List<UserOrder>> getUserOrders() async {
    final snapshot = await _firestore
        .collection(_collectionUsers)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(_collectionOrders)
        .get();
    return snapshot.docs.map((e) => UserOrder.fromMap(e.data())).toList();
  }
}
