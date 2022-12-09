import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/repos/user_repo.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit(this._userRepo)
      : super(AddressState(
          status: AddressStatus.initial,
          street: _userRepo.address?.street ?? '',
          propertyDetails: _userRepo.address?.propertyDetails ?? '',
          latitude: _userRepo.address?.latitude ?? 47.529476,
          longitude: _userRepo.address?.longitude ?? 25.558950,
        )) {
    _init();
  }

  final UserRepo _userRepo;

  _init() {
    Future.delayed(const Duration(milliseconds: 10), () {
      emit(state.copyWith(status: AddressStatus.loaded));
    });
  }

  Future<void> onLocationChanged(LatLng coordinates) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude, coordinates.longitude);

    if (placemarks.isNotEmpty) {
      emit(state.copyWith(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        street: placemarks[0].street,
        status: AddressStatus.streetSuccess,
      ));
    } else {
      emit(state.copyWith(status: AddressStatus.streetError));
    }
  }

  Future<void> onSave(
      {required String street, required String propertyDetails}) async {
    final success = await _userRepo.setDeliveryAddress(
        state.latitude, state.longitude, street, propertyDetails);
    emit(state.copyWith(
      status: success ? AddressStatus.saveSuccess : AddressStatus.saveError,
    ));
  }

  Future<void> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    emit(state.copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
      status: AddressStatus.locationChanged,
    ));
  }
}
