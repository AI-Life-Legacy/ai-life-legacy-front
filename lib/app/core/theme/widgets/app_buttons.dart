import 'package:flutter/material.dart';
import '../app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final double height;
  final bool disabled;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.height = 48,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: GestureDetector(
        onTap: (disabled || onPressed == null) ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: disabled ? AppTheme.border : AppTheme.cta,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              bottom: BorderSide(
                color: disabled ? AppTheme.textPh : AppTheme.ctaDark,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 3),
          alignment: Alignment.center,
          child: _ButtonContent(
            text: text,
            icon: icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: const Border(
              top: BorderSide(color: AppTheme.border, width: 2),
              left: BorderSide(color: AppTheme.border, width: 2),
              right: BorderSide(color: AppTheme.border, width: 2),
              bottom: BorderSide(color: AppTheme.border, width: 4),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 2),
          alignment: Alignment.center,
          child: _ButtonContent(
            text: text,
            icon: icon,
            color: AppTheme.text,
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String text;
  final Widget? icon;
  final Color color;

  const _ButtonContent({
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
