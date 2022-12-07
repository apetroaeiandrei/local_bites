import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/img.dart';
import 'package:local/theme/dimens.dart';

import '../generated/l10n.dart';
import 'address_cubit.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _mapsKey = GlobalKey();
  final Completer<GoogleMapController> _controller = Completer();
  final _addressController = TextEditingController();
  final _propertyController = TextEditingController();
  String? _addressError;
  String? _propertyDetailsError;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        _handleStateChanged(state);
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).address_title),
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      key: _mapsKey,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(state.latitude, state.longitude),
                        zoom: 16,
                      ),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onCameraIdle: () {
                        Future.delayed(
                            const Duration(
                              milliseconds: 500,
                            ), () {
                          _onLocationChanged();
                        });
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _topPinDistance,
                      child: Image.asset(
                        Img.locationPin,
                        height: Dimens.locationPinHeight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                padding: const EdgeInsets.all(Dimens.defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      enabled: false,
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: S.of(context).address_street_label,
                        errorText: _addressError,
                      ),
                    ),
                    TextField(
                      controller: _propertyController,
                      decoration: InputDecoration(
                        labelText: S.of(context).address_property_label,
                        errorText: _propertyDetailsError,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _onSave();
                      },
                      child: Text(S.of(context).generic_save),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double get _topPinDistance {
    if (_mapsKey.currentContext?.findRenderObject() == null) {
      return 0;
    }
    final RenderBox renderBox =
        _mapsKey.currentContext?.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    return size.height * 0.5 - Dimens.locationPinHeight;
  }

  Future<void> _onLocationChanged() async {
    final GoogleMapController controller = await _controller.future;
    final RenderBox renderBox =
        _mapsKey.currentContext?.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final devicePixelRatio =
        Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
    final coordinates = await controller.getLatLng(ScreenCoordinate(
        x: size.width * devicePixelRatio ~/ 2,
        y: size.height * devicePixelRatio ~/ 2));
    context.read<AddressCubit>().onLocationChanged(coordinates);
  }

  _handleStateChanged(AddressState state) {
    switch (state.status) {
      case AddressStatus.initial:
        break;
      case AddressStatus.loaded:
        _addressController.text = state.street;
        _propertyController.text = state.propertyDetails;
        break;
      case AddressStatus.streetSuccess:
        _addressController.text = state.street;
        setState(() {
          _addressError = null;
          _propertyDetailsError = null;
        });

        break;
      case AddressStatus.streetError:
        // TODO: Handle this case.
        break;
      case AddressStatus.saveSuccess:
        Navigator.of(context).pop();
        break;
      case AddressStatus.saveError:
        // TODO: Handle this case.
        break;
    }
  }

  _onSave() {
    if (_validate()) {
      context.read<AddressCubit>().onSave(
            street: _addressController.text,
            propertyDetails: _propertyController.text,
          );
    } else {
      setState(() {});
    }
  }

  _validate() {
    bool valid = true;
    if (_addressController.text.isEmpty) {
      _addressError = S.of(context).address_street_error;
      valid = false;
    } else {
      _addressError = null;
    }
    if (_propertyController.text.isEmpty) {
      _propertyDetailsError = S.of(context).address_property_error;
      valid = false;
    } else {
      _propertyDetailsError = null;
    }
    return valid;
  }
}
