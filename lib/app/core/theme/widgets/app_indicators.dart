import 'package:flutter/material.dart';
import '../app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    String text;

    switch (status) {
      case 'in-progress':
        color = AppTheme.skyDark;
        bg = const Color(0xFFE5F7FE);
        text = '진행 중';
        break;
      case 'complete':
        color = AppTheme.success;
        bg = AppTheme.successBg;
        text = '완료';
        break;
      case 'not-started':
      default:
        color = AppTheme.textSec;
        bg = AppTheme.bgAlt;
        text = '시작 전';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? fill;
  final Color? bg;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.fill,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: bg ?? AppTheme.bgAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: fill ?? AppTheme.cta,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
