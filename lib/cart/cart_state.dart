part of 'cart_cubit.dart';

enum CartStatus {
  initial,
  orderSuccess,
  orderError,
  minimumOrderError,
  restaurantClosed,
}

class CartState extends Equatable {
  final CartStatus status;
  final int cartCount;
  final double cartTotal;
  final List<FoodOrder> cartItems;
  final String mentions;
  final String restaurantName;
  final String deliveryStreet;
  final String deliveryPropertyDetails;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final num minOrder;

  @override
  List<Object> get props => [
        status,
        cartCount,
        cartTotal,
        cartItems,
        mentions,
        restaurantName,
        deliveryStreet,
        deliveryPropertyDetails,
        deliveryLatitude,
        deliveryLongitude,
        minOrder,
      ];

  const CartState({
    required this.status,
    required this.cartCount,
    required this.cartTotal,
    required this.cartItems,
    required this.mentions,
    required this.restaurantName,
    required this.deliveryStreet,
    required this.deliveryPropertyDetails,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.minOrder,
  });

  CartState copyWith({
    CartStatus? status,
    int? cartCount,
    double? cartTotal,
    List<FoodOrder>? cartItems,
    String? mentions,
    String? restaurantName,
    String? deliveryStreet,
    String? deliveryPropertyDetails,
    double? deliveryLatitude,
    double? deliveryLongitude,
    num? minOrder,
  }) {
    return CartState(
      status: status ?? this.status,
      cartCount: cartCount ?? this.cartCount,
      cartTotal: cartTotal ?? this.cartTotal,
      cartItems: cartItems ?? this.cartItems,
      mentions: mentions ?? this.mentions,
      restaurantName: restaurantName ?? this.restaurantName,
      deliveryStreet: deliveryStreet ?? this.deliveryStreet,
      deliveryPropertyDetails:
          deliveryPropertyDetails ?? this.deliveryPropertyDetails,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      minOrder: minOrder ?? this.minOrder,
    );
  }
}
