import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:models/restaurant_model.dart';

class RestaurantsRepo {
  static RestaurantsRepo? instance;
  static const String _collectionRestaurants = "restaurants";

  final _geo = Geoflutterfire();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<RestaurantModel> _restaurants = [];

  RestaurantsRepo._privateConstructor();

  factory RestaurantsRepo() {
    instance ??= RestaurantsRepo._privateConstructor();
    return instance!;
  }

  List<RestaurantModel> get restaurants => _restaurants;

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
}
