import 'package:flutter/material.dart';

/// 现代化主题配色系统
class AppTheme {
  // ============ 亮色主题 ============
  static const lightPrimary = Color(0xFFDC2626);
  static const lightPrimaryVariant = Color(0xFF991B1B);
  static const lightBackground = Color(0xFFFAFAF9);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF5F5F4);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightOnBackground = Color(0xFF1C1917);
  static const lightOnSurface = Color(0xFF1C1917);
  static const lightOnSurfaceVariant = Color(0xFF57534E);
  static const lightOutline = Color(0xFFE7E5E4);
  static const lightOutlineVariant = Color(0xFFF5F5F4);

  // ============ 暗色主题 ============
  static const darkPrimary = Color(0xFFEF4444);
  static const darkPrimaryVariant = Color(0xFFF87171);
  static const darkBackground = Color(0xFF0A0A0B);
  static const darkSurface = Color(0xFF18181B);
  static const darkSurfaceVariant = Color(0xFF27272A);
  static const darkOnPrimary = Color(0xFFFFFFFF);
  static const darkOnBackground = Color(0xFFFAFAFA);
  static const darkOnSurface = Color(0xFFFAFAFA);
  static const darkOnSurfaceVariant = Color(0xFFA1A1AA);
  static const darkOutline = Color(0xFF27272A);
  static const darkOutlineVariant = Color(0xFF1C1C1E);

  // ============ 分类颜色 ============
  static const categoryColors = {
    'writing': CategoryColor(Color(0xFFFEF3C7), Color(0xFFD97706), '✍️'),
    'work': CategoryColor(Color(0xFFDBEAFE), Color(0xFF2563EB), '💼'),
    'life': CategoryColor(Color(0xFFD1FAE5), Color(0xFF059669), '🌿'),
    'study': CategoryColor(Color(0xFFF3E8FF), Color(0xFF9333EA), '📚'),
    'idea': CategoryColor(Color(0xFFFCE7F3), Color(0xFFDB2777), '💡'),
    'diary': CategoryColor(Color(0xFFFED7E2), Color(0xFFE11D48), '📔'),
  };

  // ============ 圆角系统 ============
  static const radiusXs = 4.0;
  static const radiusSm = 6.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;
  static const radiusXxl = 32.0;

  // ============ 阴影系统 ============
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 60,
      offset: const Offset(0, 24),
    ),
  ];

  // ============ FAB阴影 ============
  static List<BoxShadow> get shadowFab => [
    BoxShadow(
      color: lightPrimary.withOpacity(0.4),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // ============ 亮色主题数据 ============
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      primaryContainer: lightPrimaryVariant,
      secondary: lightPrimary,
      surface: lightSurface,
      onPrimary: lightOnPrimary,
      onSurface: lightOnSurface,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightOnBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightOnBackground,
      ),
    ),
    cardTheme: CardTheme(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: BorderSide(color: lightOutlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(color: lightOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(color: lightOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: lightPrimary, width: 2),
      ),
      hintStyle: TextStyle(color: lightOnSurfaceVariant),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightPrimary,
      foregroundColor: lightOnPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightOutline,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: lightOnBackground,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: lightOnBackground,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightOnBackground,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Noto Sans SC',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: lightOnBackground,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: lightOnSurface,
        height: 1.8,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Noto Sans SC',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: lightOnSurfaceVariant,
        height: 1.6,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Noto Sans SC',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: lightOnSurfaceVariant,
      ),
    ),
  );

  // ============ 暗色主题数据 ============
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      primaryContainer: darkPrimaryVariant,
      secondary: darkPrimary,
      surface: darkSurface,
      onPrimary: darkOnPrimary,
      onSurface: darkOnSurface,
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkOnBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkOnBackground,
      ),
    ),
    cardTheme: CardTheme(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: BorderSide(color: darkOutlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(color: darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(color: darkOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: darkPrimary, width: 2),
      ),
      hintStyle: TextStyle(color: darkOnSurfaceVariant),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkPrimary,
      foregroundColor: darkOnPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkOutline,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: darkOnBackground,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkOnBackground,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkOnBackground,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Noto Sans SC',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: darkOnBackground,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Noto Serif SC',
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: darkOnSurface,
        height: 1.8,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Noto Sans SC',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkOnSurfaceVariant,
        height: 1.6,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Noto Sans SC',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkOnSurfaceVariant,
      ),
    ),
  );
}

/// 分类颜色数据类
class CategoryColor {
  final Color background;
  final Color text;
  final String emoji;

  const CategoryColor(this.background, this.text, this.emoji);
}
