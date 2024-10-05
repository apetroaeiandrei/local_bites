class DeliveryZone {
  final String uid;
  final num radius;
  final num deliveryFee;
  final num minimumOrder;

//<editor-fold desc="Data Methods">

  const DeliveryZone({
    required this.uid,
    required this.radius,
    required this.deliveryFee,
    required this.minimumOrder,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryZone &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          radius == other.radius &&
          deliveryFee == other.deliveryFee &&
          minimumOrder == other.minimumOrder);

  @override
  int get hashCode =>
      uid.hashCode ^
      radius.hashCode ^
      deliveryFee.hashCode ^
      minimumOrder.hashCode;

  @override
  String toString() {
    return 'DeliveryZone{' +
        ' uid: $uid,' +
        ' radius: $radius,' +
        ' deliveryFee: $deliveryFee,' +
        ' minimumOrder: $minimumOrder,' +
        '}';
  }

  DeliveryZone copyWith({
    String? uid,
    num? radius,
    num? deliveryFee,
    num? minimumOrder,
  }) {
    return DeliveryZone(
      uid: uid ?? this.uid,
      radius: radius ?? this.radius,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrder: minimumOrder ?? this.minimumOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'radius': radius,
      'deliveryFee': deliveryFee,
      'minimumOrder': minimumOrder,
    };
  }

  factory DeliveryZone.fromMap(Map<String, dynamic> map) {
    return DeliveryZone(
      uid: map['uid'] as String,
      radius: map['radius'] as num,
      deliveryFee: map['deliveryFee'] as num,
      minimumOrder: map['minimumOrder'] as num,
    );
  }

//</editor-fold>
}
