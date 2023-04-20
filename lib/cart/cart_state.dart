part of 'cart_cubit.dart';

enum CartStatus {
  initial,
  orderSuccess,
  orderPending,
  orderError,
  minimumOrderError,
  restaurantClosed,
  couriersUnavailable,
  computingDelivery,
  stripeLoading,
  stripeReady,
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
  final double restaurantLatitude;
  final double restaurantLongitude;
  final String restaurantAddress;
  final num minOrder;
  final num deliveryFee;
  final num deliveryEta;
  final num amountToMinOrder;
  final bool hasDelivery;
  final bool hasPickup;
  final bool hasDeliveryCash;
  final bool hasDeliveryCard;
  final bool hasPickupCash;
  final bool hasPickupCard;
  final bool deliverySelected;
  final bool hasExternalDelivery;
  final bool hasPayments;
  final PaymentType paymentType;
  final StripePayData? stripePayData;
  /// When generating copyWith take care of the extra clearPayData flag
  /// Used to be able to set stripePayData to null if payment method is later changed

  @override
  List<Object?> get props => [
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
        restaurantLatitude,
        restaurantLongitude,
        restaurantAddress,
        minOrder,
        deliveryFee,
        deliveryEta,
        amountToMinOrder,
        hasDelivery,
        hasPickup,
        hasDeliveryCash,
        hasDeliveryCard,
        hasPickupCash,
        hasPickupCard,
        deliverySelected,
        hasExternalDelivery,
        hasPayments,
        paymentType,
        stripePayData,
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
    required this.restaurantLatitude,
    required this.restaurantLongitude,
    required this.restaurantAddress,
    required this.minOrder,
    required this.deliveryFee,
    required this.deliveryEta,
    required this.amountToMinOrder,
    required this.hasDelivery,
    required this.hasPickup,
    required this.hasDeliveryCash,
    required this.hasDeliveryCard,
    required this.hasPickupCash,
    required this.hasPickupCard,
    required this.deliverySelected,
    required this.hasExternalDelivery,
    required this.hasPayments,
    required this.paymentType,
    this.stripePayData,
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
    double? restaurantLatitude,
    double? restaurantLongitude,
    String? restaurantAddress,
    num? minOrder,
    num? deliveryFee,
    num? deliveryEta,
    num? amountToMinOrder,
    bool? hasDelivery,
    bool? hasPickup,
    bool? hasDeliveryCash,
    bool? hasDeliveryCard,
    bool? hasPickupCash,
    bool? hasPickupCard,
    bool? deliverySelected,
    bool? hasExternalDelivery,
    bool? hasPayments,
    PaymentType? paymentType,
    StripePayData? stripePayData,
    bool clearPayData = false,
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
      restaurantLatitude: restaurantLatitude ?? this.restaurantLatitude,
      restaurantLongitude: restaurantLongitude ?? this.restaurantLongitude,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      minOrder: minOrder ?? this.minOrder,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryEta: deliveryEta ?? this.deliveryEta,
      amountToMinOrder: amountToMinOrder ?? this.amountToMinOrder,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      hasPickup: hasPickup ?? this.hasPickup,
      hasDeliveryCash: hasDeliveryCash ?? this.hasDeliveryCash,
      hasDeliveryCard: hasDeliveryCard ?? this.hasDeliveryCard,
      hasPickupCash: hasPickupCash ?? this.hasPickupCash,
      hasPickupCard: hasPickupCard ?? this.hasPickupCard,
      deliverySelected: deliverySelected ?? this.deliverySelected,
      hasExternalDelivery: hasExternalDelivery ?? this.hasExternalDelivery,
      hasPayments: hasPayments ?? this.hasPayments,
      paymentType: paymentType ?? this.paymentType,
      stripePayData: clearPayData ? null : stripePayData ?? this.stripePayData,
    );
  }
}
