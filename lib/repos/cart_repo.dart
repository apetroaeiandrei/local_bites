import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:models/food_model.dart';
import 'package:models/food_order.dart';
import 'package:models/order.dart';
import 'package:models/order_status.dart';

class CartRepo {
  static CartRepo? instance;
  static const String _collectionRestaurants = "restaurants";
  static const String _collectionOrders = "orders";
  final List<FoodOrder> _foodOrders = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedRestaurantId;

  CartRepo._privateConstructor();

  factory CartRepo() {
    instance ??= CartRepo._privateConstructor();
    return instance!;
  }

  set selectedRestaurantId(String restaurantId) {
    clearSelectedRestaurantData();
    _selectedRestaurantId = restaurantId;
  }

  addToCart(FoodModel food, int quantity) {
    final foodOrder =
        _foodOrders.firstWhere((element) => element.food == food, orElse: () {
      return FoodOrder(
        id: food.id,
        food: food,
        quantity: 0,
      );
    });
    _foodOrders.remove(foodOrder);
    _foodOrders
        .add(foodOrder.copyWith(quantity: foodOrder.quantity + quantity));
    print("addToCart: ${foodOrder.food.name}");
  }

  get cartCount =>
      _foodOrders.fold<int>(0, (sum, element) => sum + element.quantity);

  get cartTotal => _foodOrders.fold<double>(
      0, (sum, element) => sum + element.quantity * element.food.price);

  Future<bool> placeOrder() async {
    Random random = Random();
    final orderId = random.nextInt(10000);
    final Order order = Order(
        id: orderId.toString(),
        date: DateTime.now(),
        foods: _foodOrders,
        status: OrderStatus.pending);
    final restaurantDoc = _firestore
        .collection(_collectionRestaurants)
        .doc(_selectedRestaurantId);
    // try {
    //   await restaurantDoc.collection(_collectionOrders).add(order.toMap());
    //   _foodOrders.clear();
    //   return true;
    // } catch (e) {
    //   print(e);
    //   return false;
    // }
    await restaurantDoc.collection(_collectionOrders).add(order.toMap());
    return true;
  }

  void clearSelectedRestaurantData() {
    _foodOrders.clear();
  }
}
