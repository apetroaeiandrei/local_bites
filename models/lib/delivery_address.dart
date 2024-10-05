import 'package:collection/collection.dart';

enum AddressType { home, work, other }

extension AddressTypeHelper on AddressType {
  String toSimpleString() => toString().split(".")[1];

  static AddressType? fromString(String string) =>
      AddressType.values.firstWhereOrNull((e) => e.toSimpleString() == string);
}

class DeliveryAddress {
  final AddressType addressType;
  final String street;
  final String propertyDetails;
  final double latitude;
  final double longitude;

//<editor-fold desc="Data Methods">
  const DeliveryAddress({
    required this.addressType,
    required this.street,
    required this.propertyDetails,
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryAddress &&
          runtimeType == other.runtimeType &&
          addressType == other.addressType &&
          street == other.street &&
          propertyDetails == other.propertyDetails &&
          latitude == other.latitude &&
          longitude == other.longitude);

  @override
  int get hashCode =>
      addressType.hashCode ^
      street.hashCode ^
      propertyDetails.hashCode ^
      latitude.hashCode ^
      longitude.hashCode;

  @override
  String toString() {
    return 'DeliveryAddress{' +
        ' addressType: $addressType,' +
        ' street: $street,' +
        ' propertyDetails: $propertyDetails,' +
        ' latitude: $latitude,' +
        ' longitude: $longitude,' +
        '}';
  }

  DeliveryAddress copyWith({
    AddressType? addressType,
    String? addressName,
    String? street,
    String? propertyDetails,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryAddress(
      addressType: addressType ?? this.addressType,
      street: street ?? this.street,
      propertyDetails: propertyDetails ?? this.propertyDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addressType': addressType.toSimpleString(),
      'street': street,
      'propertyDetails': propertyDetails,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      addressType: AddressTypeHelper.fromString(
              map['addressType'] ?? AddressType.home.toSimpleString()) ??
          AddressType.home,
      street: map['street'] as String,
      propertyDetails: map['propertyDetails'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }

//</editor-fold>
}
