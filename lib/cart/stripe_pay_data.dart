class StripePayData{
  final String customer;
  final String ephemeralKeySecret;
  final String paymentIntentClientSecret;

//<editor-fold desc="Data Methods">
  const StripePayData({
    required this.customer,
    required this.ephemeralKeySecret,
    required this.paymentIntentClientSecret,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StripePayData &&
          runtimeType == other.runtimeType &&
          customer == other.customer &&
          ephemeralKeySecret == other.ephemeralKeySecret &&
          paymentIntentClientSecret == other.paymentIntentClientSecret);

  @override
  int get hashCode =>
      customer.hashCode ^
      ephemeralKeySecret.hashCode ^
      paymentIntentClientSecret.hashCode;

  @override
  String toString() {
    return 'StripePayData{' +
        ' customer: $customer,' +
        ' ephemeralKeySecret: $ephemeralKeySecret,' +
        ' paymentIntentClientSecret: $paymentIntentClientSecret,' +
        '}';
  }

  StripePayData copyWith({
    String? customer,
    String? ephemeralKeySecret,
    String? paymentIntentClientSecret,
  }) {
    return StripePayData(
      customer: customer ?? this.customer,
      ephemeralKeySecret: ephemeralKeySecret ?? this.ephemeralKeySecret,
      paymentIntentClientSecret:
          paymentIntentClientSecret ?? this.paymentIntentClientSecret,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer': this.customer,
      'ephemeralKeySecret': this.ephemeralKeySecret,
      'paymentIntentClientSecret': this.paymentIntentClientSecret,
    };
  }

  factory StripePayData.fromMap(Map<String, dynamic> map) {
    return StripePayData(
      customer: map['customer'] as String,
      ephemeralKeySecret: map['ephemeralKeySecret'] as String,
      paymentIntentClientSecret: map['paymentIntentClientSecret'] as String,
    );
  }

//</editor-fold>
}