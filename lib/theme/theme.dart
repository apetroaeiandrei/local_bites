import 'package:flutter/material.dart';
import 'package:local/theme/wl_colors.dart';

class AppThemeData {
  ThemeData get appThemeData {
    const textColor = WlColors.textColor;

    const letterSpacing = -0.0;
    return ThemeData(
        appBarTheme: const AppBarTheme(
          color: WlColors.surface,
          iconTheme: IconThemeData(
            color: WlColors.textColor,
          ),
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: WlColors.textColor),
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
        iconTheme: const IconThemeData(
          color: WlColors.primary,
        ),
        fontFamily: "SanFrancisco",
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1,
          ),
          displayMedium: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: letterSpacing,
            height: 1,
          ),
          displaySmall: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: letterSpacing,
            height: 1,
          ),
          headlineMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: letterSpacing,
            height: 1,
          ),
          headlineSmall: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: letterSpacing,
            height: 1,
          ),
          titleLarge: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor.withOpacity(0.8),
            letterSpacing: letterSpacing,
            height: 1,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textColor.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            height: 1,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textColor.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            letterSpacing: letterSpacing,
            height: 1,
          ),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: WlColors.surface,
          titleTextStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
        ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
    );
  }
}
