import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:models/food_category_model.dart';
import 'package:models/food_model.dart';
import 'package:models/food_option.dart';
import 'package:models/food_option_category.dart';
import 'package:models/restaurant_model.dart';

class RestaurantsRepo {
  static RestaurantsRepo? instance;
  static const String _collectionRestaurants = "restaurants";
  static const String _collectionCategories = "categories";
  static const String _propertyCategoriesOrder = "categoriesOrder";
  static const String _collectionFood = "food";
  static const String _collectionOptionCategories = "foodOptionCategories";
  static const String _collectionFoodOptionItem = "foodOptionItems";

  final _geo = Geoflutterfire();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<RestaurantModel> _restaurants = [];
  final List<FoodModel> _foods = [];
  final List<FoodCategoryModel> _categories = [];
  String? _selectedRestaurantId;
  RestaurantModel? _selectedRestaurant;
  StreamSubscription<DocumentSnapshot>? _currentRestaurantSubscription;

  RestaurantsRepo._privateConstructor();

  factory RestaurantsRepo() {
    instance ??= RestaurantsRepo._privateConstructor();
    return instance!;
  }

  set selectedRestaurantId(String restaurantId) {
    clearSelectedRestaurantData();
    _selectedRestaurantId = restaurantId;
    _selectedRestaurant = _restaurants.firstWhere(
      (element) => element.id == restaurantId,
    );
    _listenForChangesInCurrentRestaurant();
  }

  List<RestaurantModel> get restaurants => _restaurants;

  RestaurantModel get selectedRestaurant => _selectedRestaurant!;

  _listenForChangesInCurrentRestaurant() async {
    await _currentRestaurantSubscription?.cancel();
    _currentRestaurantSubscription = _firestore
        .collection(_collectionRestaurants)
        .doc(_selectedRestaurantId)
        .snapshots()
        .listen((restaurantSnapshot) {
      _handleChangedRestaurant(restaurantSnapshot);
    });
  }

  DocumentReference<Map<String, dynamic>> _getRestaurantDoc() {
    return _firestore
        .collection(_collectionRestaurants)
        .doc(_selectedRestaurantId);
  }

  Future<RestaurantModel> getRestaurantById(String restaurantId) async {
    final restaurantSnapshot = await _firestore
        .collection(_collectionRestaurants)
        .doc(restaurantId)
        .get();
    return RestaurantModel.fromMap(restaurantSnapshot.data()!);
  }

  Future<bool> getNearbyRestaurants(double latitude, double longitude) async {
    var collectionReference = _firestore.collection(_collectionRestaurants);
    GeoFirePoint center = _geo.point(latitude: latitude, longitude: longitude);

    final query = _geo.collection(collectionRef: collectionReference).within(
          center: center,
          radius: 10,
          field: 'location',
          strictMode: true,
        );
    final docs = await query.first;
    _restaurants.clear();
    _restaurants.addAll(
        docs.map((doc) => RestaurantModel.fromMap(doc.data()!)).toList());
    return true;
  }

  Future<List<FoodCategoryModel>> getCategoriesAsync() async {
    final categories =
        await _getRestaurantDoc().collection(_collectionCategories).get();
    final restaurant = await _getRestaurantDoc().get();
    final categoriesOrder =
        List<String>.from(restaurant.data()![_propertyCategoriesOrder]);
    final result = categories.docs
        .map((e) => FoodCategoryModel.fromMap(e.data()))
        .toList();
    result.sort((a, b) =>
        categoriesOrder.indexOf(a.id) - categoriesOrder.indexOf(b.id));
    _categories.clear();
    _categories.addAll(result);
    return result;
  }

  Future<void> getFoodsAsync() async {
    final foodCollection =
        await _getRestaurantDoc().collection(_collectionFood).get();
    _foods.clear();
    _foods.addAll(
        foodCollection.docs.map((e) => FoodModel.fromMap(e.data())).toList());
  }

  List<FoodModel> getFoodsContent() {
    _foods.sort((a, b) => a.name.compareTo(b.name));
    return List.from(_foods);
  }

  List<FoodCategoryModel> getCategoriesContent() {
    return _categories;
  }

  getFoodsByCategory(String id) {
    return _foods.where((element) => element.categoryId == id).toList();
  }

  void clearSelectedRestaurantData() async {
    _foods.clear();
    _categories.clear();
  }

  Future<List<FoodOptionCategory>> getFoodOptionsAsync(
      List<String> optionIds) async {
    List<FoodOptionCategory> result = [];
    for (var element in optionIds) {
      final optionCategory = await _getOptionCategory(element);
      result.add(optionCategory);
    }
    return result;
  }

  Future<FoodOptionCategory> _getOptionCategory(String id) async {
    final category = await _getRestaurantDoc()
        .collection(_collectionOptionCategories)
        .doc(id)
        .get()
        .then((e) => FoodOptionCategory.fromMap(e.data()!));

    final itemsSnapshot = await _getRestaurantDoc()
        .collection(_collectionOptionCategories)
        .doc(id)
        .collection(_collectionFoodOptionItem)
        .get();
    final List<FoodOption> items =
        itemsSnapshot.docs.map((e) => FoodOption.fromMap(e.data())).toList();
    return category.copyWith(options: items);
  }

  void _handleChangedRestaurant(
      DocumentSnapshot<Map<String, dynamic>> restaurantSnapshot) {
    final restaurant = RestaurantModel.fromMap(restaurantSnapshot.data()!);
    _selectedRestaurant = restaurant;
  }
}
