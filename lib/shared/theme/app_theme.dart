import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const background = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFF5F8FF),
    darkColor: Color(0xFF0B1220),
    highContrastColor: Color(0xFFFFFFFF),
    darkHighContrastColor: Color(0xFF000000),
  );
  static const surface = CupertinoDynamicColor.withBrightnessAndContrast(
    color: CupertinoColors.white,
    darkColor: Color(0xFF182033),
    highContrastColor: CupertinoColors.white,
    darkHighContrastColor: Color(0xFF101010),
  );
  static const ink = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF17233A),
    darkColor: Color(0xFFF4F7FF),
    highContrastColor: Color(0xFF000000),
    darkHighContrastColor: Color(0xFFFFFFFF),
  );
  static const muted = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF6D7890),
    darkColor: Color(0xFFA6AEC0),
    highContrastColor: Color(0xFF465166),
    darkHighContrastColor: Color(0xFFD8DEEA),
  );
  static const teal = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF326BFF),
    darkColor: Color(0xFF7FA2FF),
    highContrastColor: Color(0xFF0041DD),
    darkHighContrastColor: Color(0xFFB8CAFF),
  );
  static const tealDark = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF2454D6),
    darkColor: Color(0xFF9BB5FF),
    highContrastColor: Color(0xFF0030A8),
    darkHighContrastColor: Color(0xFFD6E0FF),
  );
  static const red = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFD92D3A),
    darkColor: Color(0xFFFF6B78),
    highContrastColor: Color(0xFFB00020),
    darkHighContrastColor: Color(0xFFFFB3BB),
  );
  static const warning = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFFFF7E8),
    darkColor: Color(0xFF352817),
    highContrastColor: Color(0xFFFFF3D6),
    darkHighContrastColor: Color(0xFF4A2D00),
  );
  static const warningText = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFB26A00),
    darkColor: Color(0xFFFFB84D),
    highContrastColor: Color(0xFF8A4D00),
    darkHighContrastColor: Color(0xFFFFD18A),
  );
  static const info = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFEFF5FF),
    darkColor: Color(0xFF13213B),
    highContrastColor: Color(0xFFE0EBFF),
    darkHighContrastColor: Color(0xFF07152C),
  );
  static const border = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFE2E8F5),
    darkColor: Color(0xFF2D374D),
    highContrastColor: Color(0xFFB9C3D8),
    darkHighContrastColor: Color(0xFF6E7890),
  );
  static const monthZero = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFE8EEF0),
    darkColor: Color(0xFF263040),
    highContrastColor: Color(0xFFD5DDE3),
    darkHighContrastColor: Color(0xFF485365),
  );
  static const monthLow = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFBFD0FF),
    darkColor: Color(0xFF3A5FB6),
    highContrastColor: Color(0xFF8EAAFF),
    darkHighContrastColor: Color(0xFF7399FF),
  );
  static const monthMedium = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF6F95FF),
    darkColor: Color(0xFF5E86F5),
    highContrastColor: Color(0xFF2454D6),
    darkHighContrastColor: Color(0xFFAFC3FF),
  );
  static const noticeBackground =
      CupertinoDynamicColor.withBrightnessAndContrast(
        color: Color(0xEA17233A),
        darkColor: Color(0xEA000000),
        highContrastColor: Color(0xF0000000),
        darkHighContrastColor: Color(0xF0000000),
      );
}

class AppTextStyles {
  static const body = TextStyle(color: AppColors.ink, fontSize: 17);
  static const title = TextStyle(
    color: AppColors.ink,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
  static const section = TextStyle(
    color: AppColors.ink,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const footnote = TextStyle(color: AppColors.muted, fontSize: 13);
}

extension AppColorResolver on BuildContext {
  Color appColor(Color color) => CupertinoDynamicColor.resolve(color, this);

  double get appTextScale {
    return MediaQuery.textScalerOf(this).scale(17) / 17;
  }

  bool get appPrefersStackedLayout {
    final width = MediaQuery.sizeOf(this).width;
    return appTextScale >= 1.3 || width < 360;
  }

  TextStyle appTextStyle(TextStyle style) {
    final color = style.color;
    if (color == null) {
      return style;
    }
    return style.copyWith(color: appColor(color));
  }
}

CupertinoThemeData buildCupertinoAppTheme() {
  return const CupertinoThemeData(
    primaryColor: AppColors.teal,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: CupertinoColors.systemBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.ink,
      textStyle: TextStyle(
        inherit: false,
        fontFamily: 'CupertinoSystemText',
        color: AppColors.ink,
        fontSize: 17,
        letterSpacing: 0,
        decoration: TextDecoration.none,
      ),
      navLargeTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: 'CupertinoSystemDisplay',
        color: AppColors.ink,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.38,
        decoration: TextDecoration.none,
      ),
      navTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: 'CupertinoSystemText',
        color: AppColors.ink,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        decoration: TextDecoration.none,
      ),
    ),
  );
}

ThemeData buildMaterialAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  const seed = Color(0xFF326BFF);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    primary: seed,
    surface: isDark ? const Color(0xFF182033) : CupertinoColors.white,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF0B1220)
        : const Color(0xFFF5F8FF),
    fontFamily: null,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark
          ? const Color(0xFF0B1220)
          : const Color(0xFFF5F8FF),
      foregroundColor: scheme.onSurface,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: scheme.primary,
      unselectedItemColor: isDark
          ? const Color(0xFFA6AEC0)
          : const Color(0xFF6D7890),
      backgroundColor: scheme.surface,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 17),
      bodyLarge: TextStyle(fontSize: 17),
      titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );
}
