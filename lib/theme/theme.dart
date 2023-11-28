import 'package:flutter/material.dart';
import 'package:local/theme/wl_colors.dart';

class AppThemeData {
  ThemeData get appThemeData {
    const textColor = WlColors.textColor;

    return ThemeData(
      useMaterial3: false,
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
        ),
        displaySmall: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        headlineLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textColor.withOpacity(0.8),
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor.withOpacity(0.8),
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor.withOpacity(0.8),
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
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textColor.withOpacity(0.8),
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: textColor.withOpacity(0.8),
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w300,
          color: textColor.withOpacity(0.8),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: WlColors.inputLabelTextColor,
            height: 1),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: WlColors.inputLabelTextColor,
        ),
        errorStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.1,
          color: WlColors.error,
        ),
        helperStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: WlColors.inputLabelTextColor,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: WlColors.primary,
            width: 2,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: WlColors.inputLabelTextColor,
            width: 1,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: WlColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: WlColors.error,
            width: 2,
          ),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: WlColors.surface,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            color: WlColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
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
