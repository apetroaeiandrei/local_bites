import 'package:flutter/material.dart';
import 'package:local/theme/wl_colors.dart';

class AppThemeData {
  ThemeData get appThemeData {
    const textColor = WlColors.textColor;

    const letterSpacing = -0.0;
    return ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: WlColors.onPrimary),
        ),
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: const ColorScheme(
          primary: WlColors.primary,
          secondary: WlColors.secondary,
          background: WlColors.unused,
          surface: WlColors.surface,
          onBackground: WlColors.unused,
          error: WlColors.error,
          onError: WlColors.onError,
          onPrimary: WlColors.onPrimary,
          onSecondary: WlColors.unused,
          onSurface: WlColors.onSurface,
          brightness: Brightness.light,
        ),
        indicatorColor: WlColors.secondary,
        scaffoldBackgroundColor: WlColors.surface,
        fontFamily: "SanFrancisco",
        textTheme: TextTheme(
          headline1: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1,
          ),
          headline2: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: letterSpacing,
            height: 1,
          ),
          headline3: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: letterSpacing,
            height: 1,
          ),
          headline4: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: letterSpacing,
            height: 1,
          ),
          headline5: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: letterSpacing,
            height: 1,
          ),
          headline6: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor.withOpacity(0.8),
            letterSpacing: letterSpacing,
            height: 1,
          ),
          bodyText1: TextStyle(
            fontSize: 16,
            color: textColor.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            height: 1,
          ),
          bodyText2: TextStyle(
            fontSize: 14,
            color: textColor.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            letterSpacing: letterSpacing,
            height: 1,
          ),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: WlColors.secondary,
          titleTextStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
        ));
  }
}
