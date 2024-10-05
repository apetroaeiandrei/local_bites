enum OrderStatus {
  pending,
  cooking,
  readyForDelivery,
  inDelivery,
  completed,
  cancelled,
  readyToPickup,
}

extension OrderStatusHelper on OrderStatus {
  String toSimpleString() => toString().split(".")[1];

  static OrderStatus fromString(String string) =>
      OrderStatus.values.firstWhere((e) => e.toSimpleString() == string);
}