import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:models/payment_type.dart';

import 'food_order.dart';
import 'order_status.dart';

class Order {
  final String id;
  final String number;
  final double total;
  final double totalProducts;
  final DateTime date;
  final List<FoodOrder> foods;
  final OrderStatus status;
  final String mentions;
  final bool settled;
  final bool isDelivery;
  final bool isExternalDelivery;
  final String? restaurantId;
  final num deliveryFee;
  final num deliveryFeeCompensation;
  final int eta;
  final PaymentType paymentType;
  final String paymentIntentId;

  //Delivery properties
  final int deliveryEta;
  final String courierId;
  final String courierName;
  final double companyDeliveryFee;

  //User properties
  final String userId;
  final String name;
  final String phoneNumber;

  //Address
  final String street;
  final String propertyDetails;
  final double latitude;
  final double longitude;

  //Vouchers
  final String voucherId;
  final double voucherValue;

  static List<FoodOrder> _getFoods(Map<String, dynamic> map) {
    final List<dynamic> foods = map['foods'] as List<dynamic>;
    return foods
        .map((e) => FoodOrder.fromMap(e as Map<String, dynamic>))
        .toList();
  }

//<editor-fold desc="Data Methods">

  const Order({
    required this.id,
    required this.number,
    required this.total,
    required this.totalProducts,
    required this.date,
    required this.foods,
    required this.status,
    required this.mentions,
    required this.settled,
    required this.isDelivery,
    required this.isExternalDelivery,
    required this.restaurantId,
    required this.deliveryFee,
    required this.deliveryFeeCompensation,
    required this.eta,
    required this.paymentType,
    required this.paymentIntentId,
    required this.deliveryEta,
    required this.courierId,
    required this.courierName,
    required this.companyDeliveryFee,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.propertyDetails,
    required this.latitude,
    required this.longitude,
    required this.voucherId,
    required this.voucherValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          number == other.number &&
          total == other.total &&
          totalProducts == other.totalProducts &&
          date == other.date &&
          foods == other.foods &&
          status == other.status &&
          mentions == other.mentions &&
          settled == other.settled &&
          isDelivery == other.isDelivery &&
          isExternalDelivery == other.isExternalDelivery &&
          restaurantId == other.restaurantId &&
          deliveryFee == other.deliveryFee &&
          deliveryFeeCompensation == other.deliveryFeeCompensation &&
          eta == other.eta &&
          paymentType == other.paymentType &&
          paymentIntentId == other.paymentIntentId &&
          deliveryEta == other.deliveryEta &&
          courierId == other.courierId &&
          courierName == other.courierName &&
          companyDeliveryFee == other.companyDeliveryFee &&
          userId == other.userId &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          street == other.street &&
          propertyDetails == other.propertyDetails &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          voucherId == other.voucherId &&
          voucherValue == other.voucherValue);

  @override
  int get hashCode =>
      id.hashCode ^
      number.hashCode ^
      total.hashCode ^
      totalProducts.hashCode ^
      date.hashCode ^
      foods.hashCode ^
      status.hashCode ^
      mentions.hashCode ^
      settled.hashCode ^
      isDelivery.hashCode ^
      isExternalDelivery.hashCode ^
      restaurantId.hashCode ^
      deliveryFee.hashCode ^
      deliveryFeeCompensation.hashCode ^
      eta.hashCode ^
      paymentType.hashCode ^
      paymentIntentId.hashCode ^
      deliveryEta.hashCode ^
      courierId.hashCode ^
      courierName.hashCode ^
      companyDeliveryFee.hashCode ^
      userId.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      street.hashCode ^
      propertyDetails.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      voucherId.hashCode ^
      voucherValue.hashCode;

  @override
  String toString() {
    return 'Order{' +
        ' id: $id,' +
        ' number: $number,' +
        ' total: $total,' +
        ' totalProducts: $totalProducts,' +
        ' date: $date,' +
        ' foods: $foods,' +
        ' status: $status,' +
        ' mentions: $mentions,' +
        ' settled: $settled,' +
        ' isDelivery: $isDelivery,' +
        ' isExternalDelivery: $isExternalDelivery,' +
        ' restaurantId: $restaurantId,' +
        ' deliveryFee: $deliveryFee,' +
        ' deliveryFeeCompensation: $deliveryFeeCompensation,' +
        ' eta: $eta,' +
        ' paymentType: $paymentType,' +
        ' paymentIntentId: $paymentIntentId,' +
        ' deliveryEta: $deliveryEta,' +
        ' courierId: $courierId,' +
        ' courierName: $courierName,' +
        ' companyDeliveryFee: $companyDeliveryFee,' +
        ' userId: $userId,' +
        ' name: $name,' +
        ' phoneNumber: $phoneNumber,' +
        ' street: $street,' +
        ' propertyDetails: $propertyDetails,' +
        ' latitude: $latitude,' +
        ' longitude: $longitude,' +
        ' voucherId: $voucherId,' +
        ' voucherValue: $voucherValue,' +
        '}';
  }

  Order copyWith({
    String? id,
    String? number,
    double? total,
    double? totalProducts,
    DateTime? date,
    List<FoodOrder>? foods,
    OrderStatus? status,
    String? mentions,
    bool? settled,
    bool? isDelivery,
    bool? isExternalDelivery,
    String? restaurantId,
    num? deliveryFee,
    num? deliveryFeeCompensation,
    int? eta,
    PaymentType? paymentType,
    String? paymentIntentId,
    int? deliveryEta,
    String? courierId,
    String? courierName,
    double? companyDeliveryFee,
    String? userId,
    String? name,
    String? phoneNumber,
    String? street,
    String? propertyDetails,
    double? latitude,
    double? longitude,
    String? voucherId,
    double? voucherValue,
  }) {
    return Order(
      id: id ?? this.id,
      number: number ?? this.number,
      total: total ?? this.total,
      totalProducts: totalProducts ?? this.totalProducts,
      date: date ?? this.date,
      foods: foods ?? this.foods,
      status: status ?? this.status,
      mentions: mentions ?? this.mentions,
      settled: settled ?? this.settled,
      isDelivery: isDelivery ?? this.isDelivery,
      isExternalDelivery: isExternalDelivery ?? this.isExternalDelivery,
      restaurantId: restaurantId ?? this.restaurantId,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryFeeCompensation:
          deliveryFeeCompensation ?? this.deliveryFeeCompensation,
      eta: eta ?? this.eta,
      paymentType: paymentType ?? this.paymentType,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      deliveryEta: deliveryEta ?? this.deliveryEta,
      courierId: courierId ?? this.courierId,
      courierName: courierName ?? this.courierName,
      companyDeliveryFee: companyDeliveryFee ?? this.companyDeliveryFee,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      propertyDetails: propertyDetails ?? this.propertyDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      voucherId: voucherId ?? this.voucherId,
      voucherValue: voucherValue ?? this.voucherValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'total': total,
      'totalProducts': totalProducts,
      'date': date,
      'foods': foods.map((e) => e.toMap()).toList(),
      'status': status.toSimpleString(),
      'mentions': mentions,
      'settled': settled,
      'isDelivery': isDelivery,
      'isExternalDelivery': isExternalDelivery,
      'restaurantId': restaurantId,
      'deliveryFee': deliveryFee,
      'deliveryFeeCompensation': deliveryFeeCompensation,
      'eta': eta,
      'paymentType': paymentType.toSimpleString(),
      'paymentIntentId': paymentIntentId,
      'deliveryEta': deliveryEta,
      'courierId': courierId,
      'courierName': courierName,
      'companyDeliveryFee': companyDeliveryFee,
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'street': street,
      'propertyDetails': propertyDetails,
      'latitude': latitude,
      'longitude': longitude,
      'voucherId': voucherId,
      'voucherValue': voucherValue,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      number: map['number'] as String,
      total: double.parse(map['total'].toString()),
      totalProducts: double.parse(map['totalProducts'].toString()),
      date: (map['date'] as Timestamp).toDate(),
      foods: _getFoods(map),
      status: OrderStatusHelper.fromString(map['status']),
      mentions: map['mentions'] as String,
      settled: map['settled'] as bool,
      isDelivery: map['isDelivery'] as bool,
      isExternalDelivery: map['isExternalDelivery'] ?? false,
      restaurantId: map['restaurantId'] as String?,
      deliveryFee: map['deliveryFee'] as num,
      deliveryFeeCompensation: map['deliveryFeeCompensation'] ?? 0.0,
      eta: map['eta'] ?? 0,
      paymentType: PaymentTypeHelper.fromString(map['paymentType']),
      paymentIntentId: map['paymentIntentId'] ?? '',
      deliveryEta: map['deliveryEta'] ?? 0,
      courierId: map['courierId'] ?? '',
      courierName: map['courierName'] ?? '',
      companyDeliveryFee:
          double.tryParse(map['companyDeliveryFee'].toString()) ?? 0.0,
      userId: map['userId'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      street: map['street'] as String,
      propertyDetails: map['propertyDetails'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      voucherId: map['voucherId'] ?? '',
      voucherValue: double.tryParse(map['voucherValue'].toString()) ?? 0.0,
    );
  }

//</editor-fold>
}
