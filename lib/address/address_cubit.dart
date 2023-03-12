import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/delivery_address.dart';

import '../analytics/metric.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit(this._userRepo, this._analytics)
      : super(AddressState(
          status: AddressStatus.initial,
          street: _userRepo.address?.street ?? '',
          propertyDetails: _userRepo.address?.propertyDetails ?? '',
          latitude: _userRepo.address?.latitude ?? 47.529476,
          longitude: _userRepo.address?.longitude ?? 25.558950,
          selectedType: _userRepo.address?.addressType ?? AddressType.home,
        )) {
    _init();
  }

  final UserRepo _userRepo;
  final Analytics _analytics;

  _init() {
    Future.delayed(const Duration(milliseconds: 10), () {
      emit(state.copyWith(status: AddressStatus.loaded));
    });
  }

  Future<void> onLocationChanged(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          coordinates.latitude, coordinates.longitude);
      if (isClosed) return;

      if (placemarks.isNotEmpty) {
        emit(state.copyWith(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          street: placemarks[0].street,
          status: AddressStatus.streetSuccess,
        ));
      } else {
        emit(state.copyWith(street: '', status: AddressStatus.streetError));
      }
    } catch (e) {
      emit(state.copyWith(street: '', status: AddressStatus.streetError));
    }
  }

  Future<void> onSave(
      {required String street, required String propertyDetails}) async {
    final DeliveryAddress address = DeliveryAddress(
      street: street,
      propertyDetails: propertyDetails,
      latitude: state.latitude,
      longitude: state.longitude,
      addressType: state.selectedType,
    );
    final success = await _userRepo.setDeliveryAddress(address);
    emit(state.copyWith(
      status: success ? AddressStatus.saveSuccess : AddressStatus.saveError,
    ));
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (isClosed) return;
      emit(state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        status: AddressStatus.locationChanged,
      ));
    } catch (e) {
      _analytics.logEvent(name: Metric.eventAddressLocationError);
    }
  }

  void onTypeChanged(AddressType type) {
    emit(state.copyWith(selectedType: type));
  }
}
