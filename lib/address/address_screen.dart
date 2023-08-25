import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/address/address_type_tile.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/img.dart';
import 'package:local/theme/dimens.dart';
import 'package:local/widgets/dialog_utils.dart';
import 'package:models/delivery_address.dart';
import 'package:permission_handler/permission_handler.dart';

import '../analytics/analytics.dart';
import '../generated/l10n.dart';
import 'address_cubit.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  static const double defaultCameraZoom = 16;

  final _addressController = TextEditingController();
  final _propertyController = TextEditingController();
  final _analytics = Analytics();

  GlobalKey _mapsKey = GlobalKey();
  Completer<GoogleMapController> _controller = Completer();
  String? _addressError;
  String? _propertyDetailsError;

  @override
  void initState() {
    super.initState();
    _requestAndHandleLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        _handleStateChanged(state);
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
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
                          zoom: defaultCameraZoom,
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: Dimens.defaultPadding,
                      top: 12,
                      right: Dimens.defaultPadding),
                  child: Text(
                    S.of(context).address_location_info,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AddressType.values
                        .map(
                          (e) => InkWell(
                            onTap: () {
                              context.read<AddressCubit>().onTypeChanged(e);
                            },
                            child: AddressTypeTile(
                                type: e, selected: e == state.selectedType),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                  padding: const EdgeInsets.fromLTRB(Dimens.defaultPadding, 0,
                      Dimens.defaultPadding, Dimens.defaultPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _addressController,
                        enabled: false,
                        decoration: InputDecoration(
                            labelText: S.of(context).address_street_label,
                            errorText: _addressError,
                            errorMaxLines: 2),
                      ),
                      TextField(
                        controller: _propertyController,
                        decoration: InputDecoration(
                            labelText: S.of(context).address_property_label,
                            errorText: _propertyDetailsError,
                            errorMaxLines: 2),
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
    if (_mapsKey.currentContext == null) {
      return;
    }
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
        break;
      case AddressStatus.streetSuccess:
        _analytics.logEvent(name: Metric.eventAddressStreetSuccess);
        _addressController.text = state.street;
        setState(() {
          _addressError = null;
          _propertyDetailsError = null;
        });

        break;
      case AddressStatus.streetError:
        _addressController.text = S.of(context).address_street_unknown;
        _analytics.logEvent(name: Metric.eventAddressStreetErrorBackend);
        break;
      case AddressStatus.saveSuccess:
        _analytics.logEvent(name: Metric.eventAddressSaveSuccess);
        Navigator.of(context).pop();
        break;
      case AddressStatus.saveError:
        _analytics.logEvent(name: Metric.eventAddressSaveError);
        break;
      case AddressStatus.locationChanged:
        _animateMapCamera(state.latitude, state.longitude);
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
      _analytics.logEvent(
        name: Metric.eventAddressStreetError,
      );
    } else {
      _addressError = null;
    }
    if (_propertyController.text.isEmpty) {
      _propertyDetailsError = S.of(context).address_property_error;
      valid = false;
      _analytics.logEvent(
        name: Metric.eventAddressPropertyError,
      );
    } else {
      _propertyDetailsError = null;
    }
    return valid;
  }

  _requestAndHandleLocationPermission() async {
    bool permissionGranted = await Permission.locationWhenInUse.isGranted;
    if (permissionGranted) {
      _analytics.logEvent(name: Metric.eventAddressPermissionExistedGranted);
      _getCurrentLocation();
    } else {
      _analytics.logEvent(name: Metric.eventAddressPermissionRequesting);
      permissionGranted = await Permission.location.request().isGranted;
      if (permissionGranted) {
        _analytics.logEvent(name: Metric.eventAddressPermissionGranted);
        setState(() {
          //Set new key to rebuild the widget so that myLocationButton becomes visible
          _mapsKey = GlobalKey();
          _controller = Completer();
        });
        _getCurrentLocation();
      } else {
        _analytics.logEvent(name: Metric.eventAddressPermissionDenied);
        _showPermissionNotGrantedDialog();
      }
    }
  }

  Future<void> _animateMapCamera(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: defaultCameraZoom,
        ),
      ),
    );
  }

  _showPermissionNotGrantedDialog() {
    showPlatformDialog(
      context: context,
      title: S.of(context).address_location_permission_error_title,
      content: S.of(context).address_location_permission_error_content,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).generic_ok),
        ),
      ],
    );
  }

  _getCurrentLocation() {
    context.read<AddressCubit>().getCurrentLocation();
  }
}
