import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF6F8F9);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF122024);
  static const muted = Color(0xFF687782);
  static const teal = Color(0xFF008B8B);
  static const tealDark = Color(0xFF007678);
  static const red = Color(0xFFD92D3A);
  static const warning = Color(0xFFFFF7E6);
  static const info = Color(0xFFE9F7F8);
  static const border = Color(0xFFE3E8EB);
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
