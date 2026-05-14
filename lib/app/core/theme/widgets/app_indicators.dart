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
        color = AppTheme.warning;
        bg = AppTheme.warnBg;
        text = '진행 중';
        break;
      case 'complete':
        color = AppTheme.success;
        bg = AppTheme.successBg;
        text = '완료 ✓';
        break;
      case 'not-started':
      default:
        color = AppTheme.textPh;
        bg = Colors.transparent;
        text = '시작 전';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 0.1,
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
        color: bg ?? AppTheme.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: fill ?? AppTheme.cta,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
