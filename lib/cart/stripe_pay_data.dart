class StripePayData {
  final String paymentIntentId;
  final String customer;
  final String ephemeralKeySecret;
  final String paymentIntentClientSecret;

//<editor-fold desc="Data Methods">
  const StripePayData({
    required this.paymentIntentId,
    required this.customer,
    required this.ephemeralKeySecret,
    required this.paymentIntentClientSecret,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StripePayData &&
          runtimeType == other.runtimeType &&
          paymentIntentId == other.paymentIntentId &&
          customer == other.customer &&
          ephemeralKeySecret == other.ephemeralKeySecret &&
          paymentIntentClientSecret == other.paymentIntentClientSecret);

  @override
  int get hashCode =>
      paymentIntentId.hashCode ^
      customer.hashCode ^
      ephemeralKeySecret.hashCode ^
      paymentIntentClientSecret.hashCode;

  @override
  String toString() {
    return 'StripePayData{'
        ' paymentIntentId: $paymentIntentId,'
        ' customer: $customer,'
        ' ephemeralKeySecret: $ephemeralKeySecret,'
        ' paymentIntentClientSecret: $paymentIntentClientSecret,'
        '}';
  }

  StripePayData copyWith({
    String? paymentIntentId,
    String? customer,
    String? ephemeralKeySecret,
    String? paymentIntentClientSecret,
  }) {
    return StripePayData(
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      customer: customer ?? this.customer,
      ephemeralKeySecret: ephemeralKeySecret ?? this.ephemeralKeySecret,
      paymentIntentClientSecret:
          paymentIntentClientSecret ?? this.paymentIntentClientSecret,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentIntentId': paymentIntentId,
      'customer': customer,
      'ephemeralKeySecret': ephemeralKeySecret,
      'paymentIntentClientSecret': paymentIntentClientSecret,
    };
  }

  factory StripePayData.fromMap(Map<String, dynamic> map) {
    return StripePayData(
      paymentIntentId: map['paymentIntentId'] as String,
      customer: map['customer'] as String,
      ephemeralKeySecret: map['ephemeralKeySecret'] as String,
      paymentIntentClientSecret: map['paymentIntentClientSecret'] as String,
    );
  }

//</editor-fold>
}
