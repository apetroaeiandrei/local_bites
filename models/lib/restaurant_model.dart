import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final String phone;
  final String email;
  final String website;
  final num minimumOrder;
  final int feedbackPositive;
  final int feedbackNegative;
  final GeoFirePoint location;
  final String zipCode;
  final bool acceptsVouchers;
  final bool open;
  final bool hasDelivery;
  final bool hasDeliveryCash;
  final bool hasDeliveryCard;
  final num deliveryFee;
  final bool hasPickup;
  final bool hasPickupCash;
  final bool hasPickupCard;
  final double maxRadius;
  final int defaultEta;
  final int maxPromo;
  final bool hasMenuPromo;
  final bool hasExternalDelivery;
  final bool couriersAvailable;
  final bool stripeConfigured;
  final String stripeAccountId;
  final double minExternalDelivery;
  final bool isGrocery;
  final bool useVendorDeliveryConfig;

  //Charges
  final bool paymentsV2Enabled;

  //expressed in minutes from midnight
  final int openingTime;
  final int closingTime;
  final bool scheduleActive;
  final String timeZone;

  static GeoFirePoint _getGeoFirePointFromFirebase(Map<String, dynamic> map) {
    var location = map['location']['geopoint'] as GeoPoint;
    return GeoFirePoint(location.latitude, location.longitude);
  }

//<editor-fold desc="Data Methods">

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.minimumOrder,
    required this.feedbackPositive,
    required this.feedbackNegative,
    required this.location,
    required this.zipCode,
    required this.acceptsVouchers,
    required this.open,
    required this.hasDelivery,
    required this.hasDeliveryCash,
    required this.hasDeliveryCard,
    required this.deliveryFee,
    required this.hasPickup,
    required this.hasPickupCash,
    required this.hasPickupCard,
    required this.maxRadius,
    required this.defaultEta,
    required this.minExternalDelivery,
    required this.isGrocery,
    this.maxPromo = 0,
    this.hasMenuPromo = false,
    this.hasExternalDelivery = false,
    this.couriersAvailable = true,
    this.stripeAccountId = "",
    this.stripeConfigured = false,
    this.openingTime = 0,
    this.closingTime = 0,
    this.scheduleActive = false,
    this.timeZone = "",
    this.paymentsV2Enabled = false,
    this.useVendorDeliveryConfig = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestaurantModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          address == other.address &&
          phone == other.phone &&
          email == other.email &&
          website == other.website &&
          minimumOrder == other.minimumOrder &&
          location == other.location &&
          zipCode == other.zipCode &&
          acceptsVouchers == other.acceptsVouchers &&
          open == other.open &&
          hasDelivery == other.hasDelivery &&
          hasDeliveryCash == other.hasDeliveryCash &&
          hasDeliveryCard == other.hasDeliveryCard &&
          deliveryFee == other.deliveryFee &&
          hasPickup == other.hasPickup &&
          hasPickupCash == other.hasPickupCash &&
          hasPickupCard == other.hasPickupCard &&
          maxRadius == other.maxRadius &&
          defaultEta == other.defaultEta &&
          maxPromo == other.maxPromo &&
          hasMenuPromo == other.hasMenuPromo &&
          hasExternalDelivery == other.hasExternalDelivery &&
          couriersAvailable == other.couriersAvailable &&
          stripeConfigured == other.stripeConfigured &&
          stripeAccountId == other.stripeAccountId &&
          openingTime == other.openingTime &&
          closingTime == other.closingTime &&
          scheduleActive == other.scheduleActive &&
          timeZone == other.timeZone &&
          minExternalDelivery == other.minExternalDelivery &&
          isGrocery == other.isGrocery &&
          paymentsV2Enabled == other.paymentsV2Enabled &&
          useVendorDeliveryConfig == other.useVendorDeliveryConfig);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      address.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      website.hashCode ^
      minimumOrder.hashCode ^
      location.hashCode ^
      zipCode.hashCode ^
      acceptsVouchers.hashCode ^
      open.hashCode ^
      hasDelivery.hashCode ^
      hasDeliveryCash.hashCode ^
      hasDeliveryCard.hashCode ^
      deliveryFee.hashCode ^
      hasPickup.hashCode ^
      hasPickupCash.hashCode ^
      hasPickupCard.hashCode ^
      maxRadius.hashCode ^
      defaultEta.hashCode ^
      maxPromo.hashCode ^
      hasMenuPromo.hashCode ^
      hasExternalDelivery.hashCode ^
      couriersAvailable.hashCode ^
      stripeConfigured.hashCode ^
      stripeAccountId.hashCode ^
      openingTime.hashCode ^
      closingTime.hashCode ^
      scheduleActive.hashCode ^
      timeZone.hashCode ^
      minExternalDelivery.hashCode ^
      isGrocery.hashCode ^
      paymentsV2Enabled.hashCode ^
      useVendorDeliveryConfig.hashCode;

  @override
  String toString() {
    return 'RestaurantModel{' +
        ' id: $id,' +
        ' name: $name,' +
        ' description: $description,' +
        ' imageUrl: $imageUrl,' +
        ' address: $address,' +
        ' phone: $phone,' +
        ' email: $email,' +
        ' website: $website,' +
        ' minimumOrder: $minimumOrder,' +
        ' location: $location,' +
        ' zipCode: $zipCode,' +
        ' acceptsVouchers: $acceptsVouchers,' +
        ' open: $open,' +
        ' hasDelivery: $hasDelivery,' +
        ' hasDeliveryCash: $hasDeliveryCash,' +
        ' hasDeliveryCard: $hasDeliveryCard,' +
        ' deliveryFee: $deliveryFee,' +
        ' hasPickup: $hasPickup,' +
        ' hasPickupCash: $hasPickupCash,' +
        ' hasPickupCard: $hasPickupCard,' +
        ' maxRadius: $maxRadius,' +
        ' defaultEta: $defaultEta,' +
        ' maxPromo: $maxPromo,' +
        ' hasMenuPromo: $hasMenuPromo,' +
        ' hasExternalDelivery: $hasExternalDelivery,' +
        ' couriersAvailable: $couriersAvailable,' +
        ' stripeConfigured: $stripeConfigured,' +
        ' stripeAccountId: $stripeAccountId,' +
        ' openingTime: $openingTime,' +
        ' closingTime: $closingTime,' +
        ' scheduleActive: $scheduleActive,' +
        ' timeZone: $timeZone,' +
        ' minExternalDelivery: $minExternalDelivery,' +
        ' isGrocery: $isGrocery,' +
        ' paymentsV2Enabled: $paymentsV2Enabled,' +
        ' useVendorDeliveryConfig: $useVendorDeliveryConfig,' +
        '}';
  }

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? address,
    String? phone,
    String? email,
    String? website,
    num? minimumOrder,
    int? feedbackPositive,
    int? feedbackNegative,
    GeoFirePoint? location,
    String? zipCode,
    bool? acceptsVouchers,
    bool? open,
    bool? hasDelivery,
    bool? hasDeliveryCash,
    bool? hasDeliveryCard,
    num? deliveryFee,
    bool? hasPickup,
    bool? hasPickupCash,
    bool? hasPickupCard,
    double? maxRadius,
    int? defaultEta,
    int? maxPromo,
    bool? hasMenuPromo,
    bool? hasExternalDelivery,
    bool? couriersAvailable,
    bool? stripeConfigured,
    String? stripeAccountId,
    int? openingTime,
    int? closingTime,
    bool? scheduleActive,
    String? timeZone,
    double? minExternalDelivery,
    bool? isGrocery,
    bool? paymentsV2Enabled,
    bool? useVendorDeliveryConfig,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      feedbackPositive: feedbackPositive ?? this.feedbackPositive,
      feedbackNegative: feedbackNegative ?? this.feedbackNegative,
      location: location ?? this.location,
      zipCode: zipCode ?? this.zipCode,
      acceptsVouchers: acceptsVouchers ?? this.acceptsVouchers,
      open: open ?? this.open,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      hasDeliveryCash: hasDeliveryCash ?? this.hasDeliveryCash,
      hasDeliveryCard: hasDeliveryCard ?? this.hasDeliveryCard,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      hasPickup: hasPickup ?? this.hasPickup,
      hasPickupCash: hasPickupCash ?? this.hasPickupCash,
      hasPickupCard: hasPickupCard ?? this.hasPickupCard,
      maxRadius: maxRadius ?? this.maxRadius,
      defaultEta: defaultEta ?? this.defaultEta,
      maxPromo: maxPromo ?? this.maxPromo,
      hasMenuPromo: hasMenuPromo ?? this.hasMenuPromo,
      hasExternalDelivery: hasExternalDelivery ?? this.hasExternalDelivery,
      couriersAvailable: couriersAvailable ?? this.couriersAvailable,
      stripeConfigured: stripeConfigured ?? this.stripeConfigured,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      scheduleActive: scheduleActive ?? this.scheduleActive,
      timeZone: timeZone ?? this.timeZone,
      minExternalDelivery: minExternalDelivery ?? this.minExternalDelivery,
      isGrocery: isGrocery ?? this.isGrocery,
      paymentsV2Enabled: paymentsV2Enabled ?? this.paymentsV2Enabled,
      useVendorDeliveryConfig:
          useVendorDeliveryConfig ?? this.useVendorDeliveryConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'minimumOrder': minimumOrder,
      'feedbackPositive': feedbackPositive,
      'feedbackNegative': feedbackNegative,
      'location': location.data,
      'zipCode': zipCode,
      'acceptsVouchers': acceptsVouchers,
      'open': open,
      'hasDelivery': hasDelivery,
      'hasDeliveryCash': hasDeliveryCash,
      'hasDeliveryCard': hasDeliveryCard,
      'deliveryFee': deliveryFee,
      'hasPickup': hasPickup,
      'hasPickupCash': hasPickupCash,
      'hasPickupCard': hasPickupCard,
      'maxRadius': maxRadius,
      'defaultEta': defaultEta,
      'maxPromo': maxPromo,
      'hasMenuPromo': hasMenuPromo,
      'hasExternalDelivery': hasExternalDelivery,
      'couriersAvailable': couriersAvailable,
      'stripeConfigured': stripeConfigured,
      'stripeAccountId': stripeAccountId,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'scheduleActive': scheduleActive,
      'timeZone': timeZone,
      'minExternalDelivery': minExternalDelivery,
      'isGrocery': isGrocery,
      'paymentsV2Enabled': paymentsV2Enabled,
      'useVendorDeliveryConfig': useVendorDeliveryConfig,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      website: map['website'] as String,
      minimumOrder: map['minimumOrder'] as num,
      feedbackPositive: map['feedbackPositive'] ?? 0,
      feedbackNegative: map['feedbackNegative'] ?? 0,
      location: _getGeoFirePointFromFirebase(map),
      zipCode: map['zipCode'] ?? "0",
      acceptsVouchers: map['acceptsVouchers'] ?? false,
      open: map['open'] as bool,
      hasDelivery: map['hasDelivery'] as bool,
      hasDeliveryCash: map['hasDeliveryCash'] as bool,
      hasDeliveryCard: map['hasDeliveryCard'] as bool,
      deliveryFee: map['deliveryFee'] as num,
      hasPickup: map['hasPickup'] as bool,
      hasPickupCash: map['hasPickupCash'] as bool,
      hasPickupCard: map['hasPickupCard'] as bool,
      maxRadius: double.tryParse(map['maxRadius'].toString()) ?? 15.0,
      defaultEta: map['defaultEta'] ?? 30,
      maxPromo: map['maxPromo'] ?? 0,
      hasMenuPromo: map['hasMenuPromo'] ?? false,
      hasExternalDelivery: map['hasExternalDelivery'] ?? false,
      couriersAvailable: map['couriersAvailable'] ?? true,
      stripeConfigured: map['stripeConfigured'] ?? false,
      stripeAccountId: map['stripeAccountId'] ?? '',
      openingTime: map['openingTime'] ?? 480,
      closingTime: map['closingTime'] ?? 1320,
      scheduleActive: map['scheduleActive'] ?? false,
      timeZone: map['timeZone'] ?? '',
      minExternalDelivery:
          double.tryParse(map['minExternalDelivery'].toString()) ?? 0.0,
      isGrocery: map['isGrocery'] ?? false,
      paymentsV2Enabled: map['paymentsV2Enabled'] ?? false,
      useVendorDeliveryConfig: map['useVendorDeliveryConfig'] ?? false,
    );
  }
//</editor-fold>
}
