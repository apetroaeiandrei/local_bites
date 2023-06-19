import 'package:flutter/material.dart';

abstract class WlColors {
  static const textColor = Color(0xff000000);
  static const placeholderTextColor = Color(0x77000000);

  //App bar color, separators, Fab icon
  static const primary = Color(0xFFc05746);
  //Loading Indicator
  static const primaryVariant = Color(0xFF2E6665);
  // App bar buttons, Fab background
  static const onPrimary = Color(0xFFFFFFFF);
  // Card color
  static const surface = Color(0xFFFFFFFF);
  // Buttons disabled base color
  static const onSurface = primary;
  // Used for selection checkmarks of food and tab indicator
  static const secondary = Color(0xFFadc698);

  //Error flushbar
  static const error = Color(0xFFD73A44);
  //Flushbar error text
  static const onError = Color(0xFFFFFFFF);

  static const unused = Color(0xFFFFFFFF);

  static const notificationGreen = Color(0xFF22C393);

  static const goldDark = Color.fromRGBO(209, 174, 24, 1);
  static const goldBright = Color.fromRGBO(255, 249, 133, 1);
  static const goldContrast = Color.fromRGBO(154, 72, 0, 1);
}
