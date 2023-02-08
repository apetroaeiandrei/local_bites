part of 'addresses_cubit.dart';

enum AddressesStatus { loading, loaded, empty, error }

class AddressesState extends Equatable {
  final AddressesStatus status;
  final List<DeliveryAddress> addresses;
  final DeliveryAddress? selectedAddress;

  @override
  List<Object?> get props => [status, addresses, selectedAddress];

  const AddressesState({
    required this.status,
    required this.addresses,
    this.selectedAddress,
  });

  AddressesState copyWith({
    AddressesStatus? status,
    List<DeliveryAddress>? addresses,
    DeliveryAddress? selectedAddress,
  }) {
    return AddressesState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }
}
