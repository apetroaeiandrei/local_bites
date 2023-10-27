import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:local/cart/stripe_pay_data.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/food_model.dart';
import 'package:models/food_order.dart';
import 'package:models/local_user.dart';
import 'package:models/order.dart' as o;
import 'package:models/order_status.dart';
import 'package:collection/collection.dart';
import 'package:models/payment_type.dart';

class CartRepo {
  static CartRepo? instance;
  static const String _collectionRestaurants = "restaurants";
  static const String _collectionOrders = "orders";
  final List<FoodOrder> _foodOrders = [];
  final UserRepo _userRepo;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedRestaurantId;

  String _mentions = "";

  CartRepo._privateConstructor(this._userRepo);

  factory CartRepo(UserRepo userRepo) {
    instance ??= CartRepo._privateConstructor(userRepo);
    return instance!;
  }

  String? get selectedRestaurantId => _selectedRestaurantId;

  String get mentions => _mentions;

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

  get cartTotalProducts {
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

  Future<bool> placeOrder({
    required String mentions,
    required bool isDelivery,
    required bool isExternalDelivery,
    required num deliveryFee,
    required int deliveryEta,
    required PaymentType paymentType,
    required String orderId,
    required String voucherId,
    required double voucherValue,
    required double companyDeliveryFee,
  }) async {
    final restaurantDoc = _firestore
        .collection(_collectionRestaurants)
        .doc(_selectedRestaurantId);
    final orderDoc = restaurantDoc.collection(_collectionOrders).doc();

    final o.Order order = _getOrder(
      orderDoc: orderDoc,
      mentions: mentions,
      isDelivery: isDelivery,
      deliveryFee: deliveryFee,
      deliveryEta: deliveryEta,
      paymentType: paymentType,
      orderId: orderId,
      isExternalDelivery: isExternalDelivery,
      voucherId: voucherId,
      voucherValue: voucherValue,
      companyDeliveryFee: companyDeliveryFee,
    );
    await orderDoc.set(order.toMap());
    clearCart();
    return true;
  }

  o.Order _getOrder({
    required DocumentReference<Map<String, dynamic>> orderDoc,
    required String mentions,
    required bool isDelivery,
    required bool isExternalDelivery,
    required num deliveryFee,
    required int deliveryEta,
    required PaymentType paymentType,
    required String orderId,
    required String voucherId,
    required double voucherValue,
    required double companyDeliveryFee,
  }) {
    final address = _userRepo.address!;
    final user = _userRepo.user!;

    return o.Order(
      id: orderDoc.id,
      date: DateTime.now(),
      foods: _foodOrders,
      status: OrderStatus.pending,
      mentions: mentions,
      settled: false,
      isDelivery: isDelivery,
      isExternalDelivery: isExternalDelivery,
      restaurantId: _selectedRestaurantId!,
      deliveryFee: deliveryFee,
      deliveryEta: deliveryEta,
      eta: 0,
      paymentType: paymentType,
      paymentIntentId: '',
      latitude: address.latitude,
      longitude: address.longitude,
      street: address.street,
      propertyDetails: address.propertyDetails,
      userId: user.uid,
      name: user.name,
      phoneNumber: user.phoneNumber,
      number: orderId,
      totalProducts: cartTotalProducts,
      total: cartTotalProducts + (isDelivery ? deliveryFee : 0) - voucherValue,
      courierId: '',
      courierName: '',
      companyDeliveryFee: companyDeliveryFee,
      voucherId: voucherId,
      voucherValue: voucherValue,
    );
  }

  void clearCart() {
    _mentions = "";
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

  Future<void> initStripeCheckout(
      {required String mentions,
      required bool isDelivery,
      required bool isExternalDelivery,
      required num deliveryFee,
      required int deliveryEta,
      required PaymentType paymentType,
      required LocalUser user,
      required String orderId,
      required String restaurantStripeAccountId,
      required num applicationFee,
      required double companyDeliveryFee,
      required double voucherDiscount,
      required String voucherId,
      required Function(StripePayData) callback}) async {
    final batch = _firestore.batch();

    final checkoutSessionRef = _firestore
        .collection("customers")
        .doc(user.uid)
        .collection("checkout_sessions")
        .doc();
    final checkoutSessionData = {
      "client": "mobile",
      "mode": "payment",
      "amount":
          ((cartTotalProducts + deliveryFee - voucherDiscount) * 100).round(),
      "currency": "RON",
      "application_fee_amount": (applicationFee * 100).round(),
      "on_behalf_of": restaurantStripeAccountId,
      "client_phone_number": user.phoneNumber,
      "order_id": orderId,
      "restaurantId": _selectedRestaurantId,
    };
    batch.set(checkoutSessionRef, checkoutSessionData);

    final orderRef = checkoutSessionRef.collection("pendingOrders").doc();
    final order = _getOrder(
      orderDoc: orderRef,
      mentions: mentions,
      isDelivery: isDelivery,
      deliveryFee: deliveryFee,
      deliveryEta: deliveryEta,
      paymentType: paymentType,
      orderId: orderId,
      isExternalDelivery: isExternalDelivery,
      voucherId: voucherId,
      voucherValue: voucherDiscount.toDouble(),
      companyDeliveryFee: companyDeliveryFee,
    );
    batch.set(orderRef, order.toMap());

    await batch.commit();

    checkoutSessionRef.snapshots().listen((event) {
      try {
        if (event.data()!['paymentIntentId'] != null) {
          callback(StripePayData.fromMap(event.data()!));
        }
      } catch (e) {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      }
    });
  }

  void updateMentions(String mentions) {
    _mentions = mentions;
  }
}
