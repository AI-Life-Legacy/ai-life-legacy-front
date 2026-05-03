import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgAlt = Color(0xFFF7F7F5);
  static const Color text = Color(0xFF37352F);
  static const Color textSec = Color(0xFF6B6B6B);
  static const Color textPh = Color(0xFF9B9A97);
  static const Color border = Color(0xFFE9E9E7);
  static const Color cta = Color(0xFF2F3437);
  static const Color success = Color(0xFF4DAB9A);
  static const Color warning = Color(0xFFCB912F);
  static const Color error = Color(0xFFD44C47);
  static const Color warnBg = Color(0xFFFFFBF0);
  static const Color warnBorder = Color(0xFFFDE68A);
  static const Color successBg = Color(0xFFF0FAF8);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color highlight = Color(0xFFFEF9C3);

  // Fonts
  static const String fontFamily = 'Inter'; // Ensure Inter is in pubspec.yaml

  // Text Styles
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
    fontWeight: FontWeight.w600,
    letterSpacing: 0.33, // approx 0.03em
    color: textPh,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    color: textPh,
  );

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: bg,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cta,
        primary: cta,
        secondary: success,
        background: bg,
        surface: bg,
        error: error,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
          letterSpacing: -0.2,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: textPrimary,
      ),
      useMaterial3: true,
    );
  }
}
