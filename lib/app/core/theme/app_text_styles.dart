import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.18,
    color: AppTheme.text,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: AppTheme.text,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.3,
    color: AppTheme.text,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.6,
    color: AppTheme.text,
  );

  static const TextStyle bodySec = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppTheme.textSec,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppTheme.textSec,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppTheme.textPh,
    height: 1.4,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppTheme.textPh,
    letterSpacing: 0,
  );
}
