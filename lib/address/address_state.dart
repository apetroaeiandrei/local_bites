part of 'address_cubit.dart';

enum AddressStatus {
  initial,
  loaded,
  streetSuccess,
  streetError,
  saveSuccess,
  saveError,
  locationChanged
}

class AddressState extends Equatable {
  final AddressStatus status;
  final String street;
  final String propertyDetails;
  final double latitude;
  final double longitude;
  final AddressType selectedType;

  @override
  List<Object?> get props =>
      [status, street, propertyDetails, latitude, longitude, selectedType];

  const AddressState({
    required this.status,
    required this.street,
    required this.propertyDetails,
    required this.latitude,
    required this.longitude,
    required this.selectedType,
  });

  AddressState copyWith({
    AddressStatus? status,
    String? street,
    String? propertyDetails,
    double? latitude,
    double? longitude,
    AddressType? selectedType,
  }) {
    return AddressState(
      status: status ?? this.status,
      street: street ?? this.street,
      propertyDetails: propertyDetails ?? this.propertyDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}
