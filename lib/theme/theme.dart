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
        onBackground: WlColors.gray1,
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
      fontFamily: "Poppins",
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
        headlineLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: letterSpacing,
          height: 1,
        ),
        headlineMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: letterSpacing,
          height: 1,
        ),
        headlineSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: letterSpacing,
          height: 1,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textColor.withOpacity(0.8),
          letterSpacing: letterSpacing,
          height: 1,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor.withOpacity(0.8),
          letterSpacing: letterSpacing,
          height: 1,
        ),
        titleSmall: TextStyle(
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
        bodySmall: TextStyle(
          fontSize: 12,
          color: textColor.withOpacity(0.8),
          fontWeight: FontWeight.w400,
          letterSpacing: letterSpacing,
          height: 1,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          letterSpacing: letterSpacing,
          height: 1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: textColor.withOpacity(0.8),
          letterSpacing: letterSpacing,
          height: 1,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w300,
          color: textColor.withOpacity(0.8),
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
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          backgroundColor: WlColors.secondaryButtonColor,
          foregroundColor: WlColors.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
