import 'dart:math' as math;

import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:flutter/material.dart';

class MascotFlowTheme {
  static const Color bg = AppTheme.bg;
  static const Color surface = AppTheme.surface;
  static const Color surfaceAlt = AppTheme.surfaceElevated;
  static const Color border = AppTheme.border;
  static const Color active = AppTheme.cta;
  static const Color text = AppTheme.text;
  static const Color textMuted = AppTheme.textSec;
}

class MascotScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottom;
  final EdgeInsets padding;
  final bool scrollable;

  const MascotScaffold({
    super.key,
    required this.child,
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 20),
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: scrollable ? SingleChildScrollView(child: body) : body,
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}

class MascotHeader extends StatelessWidget {
  final String message;
  final double mascotSize;
  final MascotMood mood;
  final Widget? trailing;

  const MascotHeader({
    super.key,
    required this.message,
    this.mascotSize = 64,
    this.mood = MascotMood.idle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedMascot(size: mascotSize, mood: mood),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

enum SpeechBubbleTail {
  left,
  right,
  bottomLeft,
  none,
}

class SpeechBubble extends StatelessWidget {
  final String text;
  final SpeechBubbleTail tail;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const SpeechBubble({
    super.key,
    required this.text,
    this.tail = SpeechBubbleTail.none,
    this.backgroundColor = AppTheme.surface,
    this.borderColor = AppTheme.border,
    this.textColor = AppTheme.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class MascotCoachBubble extends StatelessWidget {
  final String message;
  final MascotMood mood;
  final double mascotSize;
  final double maxBubbleWidth;

  const MascotCoachBubble({
    super.key,
    required this.message,
    this.mood = MascotMood.idle,
    this.mascotSize = 132,
    this.maxBubbleWidth = 320,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: math.max(mascotSize, maxBubbleWidth),
      child: Column(
        children: [
          AnimatedMascot(size: mascotSize, mood: mood),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: SpeechBubble(text: message),
          ),
        ],
      ),
    );
  }
}

class FlowOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const FlowOptionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppTheme.text : AppTheme.border;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppTheme.surfaceElevated : AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 68),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accent, width: selected ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.sun : AppTheme.bgAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.text, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.text,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: AppTheme.textSec,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textPh),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlowPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const FlowPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.text,
          disabledBackgroundColor: AppTheme.border,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class FlowProgressPill extends StatelessWidget {
  final double value;
  final String label;

  const FlowProgressPill({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).clamp(0, 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: AppTheme.ctaDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: 9,
              backgroundColor: AppTheme.bgAlt,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cta),
            ),
          ),
        ],
      ),
    );
  }
}
