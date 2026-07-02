import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFFFFE04B);
  static const Color bgAlt = Color(0xFFFFF0A8);
  static const Color surface = Color(0xFFFFF3B8);
  static const Color surfaceElevated = Color(0xFFB8EFBC);
  static const Color text = Color(0xFF111514);
  static const Color textSec = Color(0xFF4B5451);
  static const Color textPh = Color(0xFF7C8782);
  static const Color border = Color(0xFFD9DDD3);
  static const Color borderSoft = Color(0xFFE9ECE4);
  static const Color cta = Color(0xFF21B45B);
  static const Color ctaDark = Color(0xFF087E3A);
  static const Color sky = Color(0xFF24B7E7);
  static const Color skyDark = Color(0xFF087DA4);
  static const Color sun = Color(0xFFFFD84F);
  static const Color coral = Color(0xFFFF6333);
  static const Color lavender = Color(0xFFEF8EDB);
  static const Color success = Color(0xFF21B45B);
  static const Color warning = Color(0xFFE6A600);
  static const Color error = Color(0xFFE74635);
  static const Color warnBg = Color(0xFFFFF4C7);
  static const Color warnBorder = Color(0xFFE8C540);
  static const Color successBg = Color(0xFFDFF6E7);
  static const Color errorBg = Color(0xFFFFE4DF);
  static const Color highlight = Color(0xFFFFF3A6);
  static const Color shadow = Color(0x1F111514);

  static const String fontFamily = 'Inter';

  static const TextStyle textPrimary = TextStyle(
    fontFamily: fontFamily,
    color: text,
  );

  static const TextStyle textSecondary = TextStyle(
    fontFamily: fontFamily,
    color: textSec,
  );

  static const TextStyle textPlaceholder = TextStyle(
    fontFamily: fontFamily,
    color: textPh,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: textPh,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    color: textPh,
  );

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: cta,
        primary: cta,
        secondary: sky,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSurface: text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: 0,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: textSec,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgAlt,
        hintStyle: const TextStyle(color: textPh),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: text, width: 1.5),
        ),
      ),
      useMaterial3: true,
    );
  }
}
