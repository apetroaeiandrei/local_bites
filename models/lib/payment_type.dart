enum PaymentType {cash, card, app, unknown}

extension PaymentTypeHelper on PaymentType {
  String toSimpleString() => toString().split(".")[1];

  static PaymentType fromString(String? value) {
    switch (value) {
      case 'cash':
        return PaymentType.cash;
      case 'card':
        return PaymentType.card;
      case 'app':
        return PaymentType.app;
      default:
        return PaymentType.unknown;
    }
  }

}