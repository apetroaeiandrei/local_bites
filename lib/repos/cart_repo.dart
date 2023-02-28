import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local/cart/stripe_pay_data.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/food_model.dart';
import 'package:models/food_order.dart';
import 'package:models/local_user.dart';
import 'package:models/order.dart' as o;
import 'package:models/order_status.dart';
import 'package:collection/collection.dart';

class CartRepo {
  static CartRepo? instance;
  static const String _collectionRestaurants = "restaurants";
  static const String _collectionOrders = "orders";
  final List<FoodOrder> _foodOrders = [];
  final UserRepo _userRepo;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedRestaurantId;

  CartRepo._privateConstructor(this._userRepo);

  factory CartRepo(UserRepo userRepo) {
    instance ??= CartRepo._privateConstructor(userRepo);
    return instance!;
  }

  String? get selectedRestaurantId => _selectedRestaurantId;

  set selectedRestaurantId(String? restaurantId) {
    if (_selectedRestaurantId == null ||
        _selectedRestaurantId != restaurantId) {
      _selectedRestaurantId = restaurantId;
      clearCart();
    }
  }

  addToCart(FoodModel food, int quantity,
      Map<String, List<String>> selectedOptions, double price) {
    final foodOrder = _foodOrders.firstWhere((element) {
      return element.food == food &&
          const DeepCollectionEquality()
              .equals(element.selectedOptions, selectedOptions);
    }, orElse: () {
      return FoodOrder(
        id: food.id,
        food: food,
        quantity: 0,
        selectedOptions: selectedOptions,
        price: price,
      );
    });

    bool elementExists = _foodOrders.remove(foodOrder);
    _foodOrders.add(foodOrder.copyWith(
        quantity: foodOrder.quantity + quantity,
        price: elementExists ? foodOrder.price + price : price));
  }

  get cartCount =>
      _foodOrders.fold<int>(0, (sum, element) => sum + element.quantity);

  get cartTotal {
    double total =
        _foodOrders.fold<double>(0, (sum, element) => sum + element.price);
    total = double.parse(total.toStringAsFixed(2));
    return total;
  }

  List<FoodOrder> get cartItems {
    final sortedFoods = List<FoodOrder>.from(_foodOrders);
    sortedFoods.sort((a, b) {
      if (a.food.name == b.food.name) {
        return a.selectedOptions
            .toString()
            .compareTo(b.selectedOptions.toString());
      }
      return a.food.name.compareTo(b.food.name);
    });
    return sortedFoods;
  }

  Future<bool> placeOrder(String mentions, bool isDelivery, num deliveryFee,
      int deliveryEta) async {
    final address = _userRepo.address!;
    final user = _userRepo.user!;

    final restaurantDoc = _firestore
        .collection(_collectionRestaurants)
        .doc(_selectedRestaurantId);
    final orderDoc = restaurantDoc.collection(_collectionOrders).doc();

    final o.Order order = o.Order(
      id: orderDoc.id,
      date: DateTime.now(),
      foods: _foodOrders,
      status: OrderStatus.pending,
      mentions: mentions,
      settled: false,
      isDelivery: isDelivery,
      deliveryFee: deliveryFee,
      deliveryEta: deliveryEta,
      eta: 0,
      latitude: address.latitude,
      longitude: address.longitude,
      street: address.street,
      propertyDetails: address.propertyDetails,
      userId: user.uid,
      name: user.name,
      phoneNumber: user.phoneNumber,
      number: Random().nextInt(1000).toString(),
      totalProducts: cartTotal,
      total: cartTotal + (isDelivery ? deliveryFee : 0),
      courierId: '',
      courierName: '',
    );
    await orderDoc.set(order.toMap());
    clearCart();
    return true;
  }

  void clearCart() {
    _foodOrders.clear();
  }

  void increaseItemQuantity(FoodOrder item) {
    final foodOrder = _foodOrders.firstWhere((element) => element == item);
    final itemPrice = foodOrder.price / foodOrder.quantity;
    _foodOrders.remove(foodOrder);
    _foodOrders.add(foodOrder.copyWith(
      quantity: foodOrder.quantity + 1,
      price: foodOrder.price + itemPrice,
    ));
  }

  void decreaseItemQuantity(FoodOrder item) {
    final foodOrder = _foodOrders.firstWhere((element) => element == item);
    final itemPrice = foodOrder.price / foodOrder.quantity;
    _foodOrders.remove(foodOrder);
    if (foodOrder.quantity > 1) {
      _foodOrders.add(foodOrder.copyWith(
        quantity: foodOrder.quantity - 1,
        price: foodOrder.price - itemPrice,
      ));
    }
  }

  Future<void> initStripeCheckout(LocalUser user, Function(StripePayData) callback) async {
    final doc = await _firestore
        .collection("customers")
        .doc(user.uid)
        .collection("checkout_sessions")
        .add({
      "client": "mobile",
      "mode": "payment",
      "amount": cartTotal * 100,
      "currency": "RON",
      "payment_method_types": ["card"],
    });

    doc.snapshots().listen((event) {
      print(event.data());
      try {
        callback(StripePayData.fromMap(event.data()!));
      } catch (e) {
        print(e);
      }
    });

  }
}
