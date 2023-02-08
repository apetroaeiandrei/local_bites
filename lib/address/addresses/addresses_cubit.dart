import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:models/delivery_address.dart';

import '../../analytics/analytics.dart';
import '../../repos/user_repo.dart';

part 'addresses_state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit(this._userRepo, this._analytics)
      : super(const AddressesState(
          status: AddressesStatus.loading,
          addresses: [],
        )) {
    _init();
  }

  final UserRepo _userRepo;
  final Analytics _analytics;
  StreamSubscription? _addressesSubscription;

  _init() async {
    _addressesSubscription = _userRepo.addressesStream.listen((addresses) {
      print('addresses cubit listener: $addresses');
      emit(state.copyWith(
        status: AddressesStatus.loaded,
        addresses: addresses,
        selectedAddress: _userRepo.address,
      ));
    });

    _userRepo.listenForAddresses();
    Future.delayed(const Duration(milliseconds: 10), () {
      final addresses = _userRepo.addresses;
      emit(state.copyWith(
        selectedAddress: _userRepo.address,
        addresses: addresses,
        status:
            addresses.isEmpty ? AddressesStatus.empty : AddressesStatus.loaded,
      ));
    });
  }

  Future<void> onAddressSelected(DeliveryAddress address) async {
    final success = await _userRepo.setDeliveryAddress(address);
    if (success) {
      emit(state.copyWith(selectedAddress: address));
      //_analytics.logEvent(Metric.addressSelected);
    }
  }

  void deleteAddress(DeliveryAddress address) {
    _userRepo.deleteAddress(address);
  }

  @override
  Future<void> close() async {
    await _addressesSubscription?.cancel();
    return super.close();
  }
}
