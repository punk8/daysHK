import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF5F8FF);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF17233A);
  static const muted = Color(0xFF6D7890);
  static const teal = Color(0xFF326BFF);
  static const tealDark = Color(0xFF2454D6);
  static const red = Color(0xFFD92D3A);
  static const warning = Color(0xFFFFF7E8);
  static const info = Color(0xFFEFF5FF);
  static const border = Color(0xFFE2E8F5);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    primary: AppColors.teal,
    error: AppColors.red,
    surface: AppColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'PingFang SC',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: AppColors.ink),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size.fromHeight(52),
      ),
    ),
  );
}
