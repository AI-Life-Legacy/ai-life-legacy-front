import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color bg = Color(0xFF081116);
  static const Color bgAlt = Color(0xFF101D24);
  static const Color surface = Color(0xFF13262E);
  static const Color text = Color(0xFFF3FAF7);
  static const Color textSec = Color(0xFFB3C4C8);
  static const Color textPh = Color(0xFF71868C);
  static const Color border = Color(0xFF29444C);
  static const Color cta = Color(0xFF58CC02);
  static const Color ctaDark = Color(0xFF86E04A);
  static const Color sky = Color(0xFF35BDF8);
  static const Color skyDark = Color(0xFF7AD8FF);
  static const Color sun = Color(0xFFFFD84D);
  static const Color coral = Color(0xFFFF7D7D);
  static const Color lavender = Color(0xFFD79DFF);
  static const Color success = Color(0xFF58CC02);
  static const Color warning = Color(0xFFFFC04D);
  static const Color error = Color(0xFFFF6666);
  static const Color warnBg = Color(0xFF352A12);
  static const Color warnBorder = Color(0xFF8C6B1D);
  static const Color successBg = Color(0xFF173319);
  static const Color errorBg = Color(0xFF37191C);
  static const Color highlight = Color(0xFF4D451E);
  static const Color shadow = Color(0xFF02080B);

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
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgAlt,
        hintStyle: const TextStyle(color: textPh),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: cta, width: 2),
        ),
      ),
      useMaterial3: true,
    );
  }
}
