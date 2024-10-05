import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class NoGoZone{
  final String id;
  final String name;
  final String reason;
  final GeoFirePoint location;
  final num radius;
  final bool active;

  static GeoFirePoint _getGeoFirePointFromFirebase(Map<String, dynamic> map) {
    var location = map['location']['geopoint'] as GeoPoint;
    return GeoFirePoint(location.latitude, location.longitude);
  }

//<editor-fold desc="Data Methods">
  const NoGoZone({
    required this.id,
    required this.name,
    required this.reason,
    required this.location,
    required this.radius,
    required this.active,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoGoZone &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          reason == other.reason &&
          location == other.location &&
          radius == other.radius &&
          active == other.active);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      reason.hashCode ^
      location.hashCode ^
      radius.hashCode ^
      active.hashCode;

  @override
  String toString() {
    return 'NoGoZone{' +
        ' id: $id,' +
        ' name: $name,' +
        ' reason: $reason,' +
        ' location: $location,' +
        ' radius: $radius,' +
        ' active: $active,' +
        '}';
  }

  NoGoZone copyWith({
    String? id,
    String? name,
    String? reason,
    GeoFirePoint? location,
    num? radius,
    bool? active,
  }) {
    return NoGoZone(
      id: id ?? this.id,
      name: name ?? this.name,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reason': reason,
      'location': location.data,
      'radius': radius,
      'active': active,
    };
  }

  factory NoGoZone.fromMap(Map<String, dynamic> map) {
    return NoGoZone(
      id: map['id'] as String,
      name: map['name'] as String,
      reason: map['reason'] as String,
      location: _getGeoFirePointFromFirebase(map),
      radius: map['radius'] as num,
      active: map['active'] as bool,
    );
  }

//</editor-fold>
}