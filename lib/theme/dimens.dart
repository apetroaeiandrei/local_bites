import 'package:flutter/cupertino.dart';

abstract class Dimens {
  static const goldenRatio = 1.61803399;

  static const defaultPadding = 20.0;
  static const cardCornerRadius = 15.0;
  static const profileCardElevation = 4.0;
  static const foodCardPhotoSize = 70.0;
  static const orderCommentsHeight = 100.0;
  static const homeCardHeight = 200.0;

  static const buttonCornerRadius = 4.0;
  static const actionButtonsHeight = 48.0;

  static const space_4 = 4.0;
  static const space_8 = 8.0;
  static const space_12 = 12.0;
  static const space_16 = 16.0;
  static const space_20 = 20.0;
  static const space_24 = 24.0;
  static const space_30 = 30.0;

  static const sliverAppBarHeight = 170.0;
  static const sliverImageHeight = 230.0;
  static const actionIconSize = 40.0;
  static const actionIconSidePadding = 16.0;
  static const locationPinHeight = 50.0;

  static const maxWidth = 500.0;

  static const double foodCardPhotoRadius = 10.0;

  static double getGoldenRatioFromWidth(BuildContext context) {
    return MediaQuery.of(context).size.width / goldenRatio;
  }

}