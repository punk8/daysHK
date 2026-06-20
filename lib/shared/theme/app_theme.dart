import 'package:flutter/cupertino.dart';

class AppColors {
  static const background = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF5F8FF),
    darkColor: Color(0xFF0B1220),
  );
  static const surface = CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: Color(0xFF182033),
  );
  static const ink = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF17233A),
    darkColor: Color(0xFFF4F7FF),
  );
  static const muted = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF6D7890),
    darkColor: Color(0xFFA6AEC0),
  );
  static const teal = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF326BFF),
    darkColor: Color(0xFF7FA2FF),
  );
  static const tealDark = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF2454D6),
    darkColor: Color(0xFF9BB5FF),
  );
  static const red = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFD92D3A),
    darkColor: Color(0xFFFF6B78),
  );
  static const warning = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFF7E8),
    darkColor: Color(0xFF352817),
  );
  static const info = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFEFF5FF),
    darkColor: Color(0xFF13213B),
  );
  static const border = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE2E8F5),
    darkColor: Color(0xFF2D374D),
  );
  static const monthZero = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE8EEF0),
    darkColor: Color(0xFF263040),
  );
  static const monthLow = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFBFD0FF),
    darkColor: Color(0xFF3A5FB6),
  );
  static const monthMedium = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF6F95FF),
    darkColor: Color(0xFF5E86F5),
  );
  static const noticeBackground = CupertinoDynamicColor.withBrightness(
    color: Color(0xEA17233A),
    darkColor: Color(0xEA000000),
  );
}

class AppTextStyles {
  static const body = TextStyle(color: AppColors.ink, fontSize: 14);
  static const title = TextStyle(
    color: AppColors.ink,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );
  static const section = TextStyle(
    color: AppColors.ink,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const footnote = TextStyle(color: AppColors.muted, fontSize: 13);
}

extension AppColorResolver on BuildContext {
  Color appColor(Color color) => CupertinoDynamicColor.resolve(color, this);

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
      textStyle: TextStyle(color: AppColors.ink, fontSize: 17),
      navLargeTitleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
      navTitleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
