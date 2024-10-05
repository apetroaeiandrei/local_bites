import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:models/order_status.dart';
import 'package:models/payment_type.dart';

class UserOrder {
  final DateTime date;
  final String orderId;
  final String restaurantId;
  final String restaurantName;
  final OrderStatus status;
  final double total;
  final int eta;
  final PaymentType paymentType;
  final bool isDelivery;
  final bool settled;
  final String courierId;
  final String courierName;

//<editor-fold desc="Data Methods">

  const UserOrder({
    required this.date,
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
    required this.status,
    required this.total,
    required this.eta,
    required this.paymentType,
    required this.isDelivery,
    required this.settled,
    required this.courierId,
    required this.courierName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserOrder &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          orderId == other.orderId &&
          restaurantId == other.restaurantId &&
          restaurantName == other.restaurantName &&
          status == other.status &&
          total == other.total &&
          eta == other.eta &&
          paymentType == other.paymentType &&
          isDelivery == other.isDelivery &&
          settled == other.settled &&
          courierId == other.courierId &&
          courierName == other.courierName);

  @override
  int get hashCode =>
      date.hashCode ^
      orderId.hashCode ^
      restaurantId.hashCode ^
      restaurantName.hashCode ^
      status.hashCode ^
      total.hashCode ^
      eta.hashCode ^
      paymentType.hashCode ^
      isDelivery.hashCode ^
      settled.hashCode ^
      courierId.hashCode ^
      courierName.hashCode;

  @override
  String toString() {
    return 'UserOrder{' +
        ' date: $date,' +
        ' orderId: $orderId,' +
        ' restaurantId: $restaurantId,' +
        ' restaurantName: $restaurantName,' +
        ' status: $status,' +
        ' total: $total,' +
        ' eta: $eta,' +
        ' paymentType: $paymentType,' +
        ' isDelivery: $isDelivery,' +
        ' settled: $settled,' +
        ' courierId: $courierId,' +
        ' courierName: $courierName,' +
        '}';
  }

  UserOrder copyWith({
    DateTime? date,
    String? orderId,
    String? restaurantId,
    String? restaurantName,
    OrderStatus? status,
    double? total,
    int? eta,
    PaymentType? paymentType,
    bool? isDelivery,
    bool? settled,
    String? courierId,
    String? courierName,
  }) {
    return UserOrder(
      date: date ?? this.date,
      orderId: orderId ?? this.orderId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      status: status ?? this.status,
      total: total ?? this.total,
      eta: eta ?? this.eta,
      paymentType: paymentType ?? this.paymentType,
      isDelivery: isDelivery ?? this.isDelivery,
      settled: settled ?? this.settled,
      courierId: courierId ?? this.courierId,
      courierName: courierName ?? this.courierName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'orderId': orderId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'status': status.toSimpleString(),
      'total': total,
      'eta': eta,
      'paymentType': paymentType.toSimpleString(),
      'isDelivery': isDelivery,
      'settled': settled,
      'courierId': courierId,
      'courierName': courierName,
    };
  }

  factory UserOrder.fromMap(Map<String, dynamic> map) {
    return UserOrder(
      date: (map['date'] as Timestamp).toDate(),
      orderId: map['orderId'] as String,
      restaurantId: map['restaurantId'] as String,
      restaurantName: map['restaurantName'] as String,
      status: OrderStatusHelper.fromString(map['status']),
      total: (map['total'] as num).toDouble(),
      eta: map['eta'] ?? 0,
      paymentType: PaymentTypeHelper.fromString(map['paymentType']),
      isDelivery: map['isDelivery'] ?? false,
      settled: map['settled'] as bool,
      courierId: map['courierId'] ?? '',
      courierName: map['courierName'] ?? '',
    );
  }

//</editor-fold>
}
