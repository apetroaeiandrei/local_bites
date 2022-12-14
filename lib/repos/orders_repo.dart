import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:models/order.dart' as o;
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
        .where("settled", isEqualTo: false);
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

  Future<o.Order> getOrder(String orderId, String restaurantId) async {
    final orderSnapshot = await _firestore
        .collection(_collectionRestaurants)
        .doc(restaurantId)
        .collection(_collectionOrders)
        .doc(orderId)
        .get();
    return o.Order.fromMap(orderSnapshot.data()!);
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
    final orders = snapshot.docs.map((e) => UserOrder.fromMap(e.data())).toList();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  void rateOrder(UserOrder currentOrder, bool? liked) {
    //todo implement rating. For now used only for settlement
    _firestore
        .collection(_collectionUsers)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(_collectionOrders)
        .doc(currentOrder.orderId)
        .update({"settled": true});
  }
}
