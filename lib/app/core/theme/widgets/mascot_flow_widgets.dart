import 'dart:math' as math;

import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:ai_life_legacy/app/core/theme/widgets/animated_mascot.dart';
import 'package:flutter/material.dart';

class MascotFlowTheme {
  static const Color bg = Color(0xFF0F2026);
  static const Color surface = Color(0xFF142A31);
  static const Color surfaceAlt = Color(0xFF193640);
  static const Color border = Color(0xFF35505A);
  static const Color active = Color(0xFF1CB0F6);
  static const Color text = Color(0xFFF5FAFC);
  static const Color textMuted = Color(0xFF87A4AF);
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
      backgroundColor: MascotFlowTheme.bg,
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
    this.mascotSize = 78,
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
            child: SpeechBubble(text: message, tail: SpeechBubbleTail.left)),
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
    this.tail = SpeechBubbleTail.left,
    this.backgroundColor = MascotFlowTheme.surface,
    this.borderColor = MascotFlowTheme.border,
    this.textColor = MascotFlowTheme.text,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubblePainter(
        tail: tail,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          tail == SpeechBubbleTail.left ? 18 : 16,
          13,
          tail == SpeechBubbleTail.right ? 18 : 16,
          tail == SpeechBubbleTail.bottomLeft ? 18 : 13,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final SpeechBubbleTail tail;
  final Color backgroundColor;
  final Color borderColor;

  const _SpeechBubblePainter({
    required this.tail,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(12);
    final fill = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final leftInset = tail == SpeechBubbleTail.left ? 10.0 : 0.0;
    final rightInset = tail == SpeechBubbleTail.right ? 10.0 : 0.0;
    final bottomInset = tail == SpeechBubbleTail.bottomLeft ? 10.0 : 0.0;
    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        leftInset,
        0,
        size.width - leftInset - rightInset,
        size.height - bottomInset,
      ),
      radius,
    );

    final tailPath = _tailPath(size);
    if (tailPath != null) canvas.drawPath(tailPath, fill);
    canvas.drawRRect(bubble, fill);
    if (tailPath != null) canvas.drawPath(tailPath, stroke);
    canvas.drawRRect(bubble, stroke);
  }

  Path? _tailPath(Size size) {
    switch (tail) {
      case SpeechBubbleTail.left:
        return Path()
          ..moveTo(10, size.height * 0.55)
          ..lineTo(0, size.height * 0.72)
          ..lineTo(13, size.height * 0.72)
          ..close();
      case SpeechBubbleTail.right:
        return Path()
          ..moveTo(size.width - 10, size.height * 0.55)
          ..lineTo(size.width, size.height * 0.72)
          ..lineTo(size.width - 13, size.height * 0.72)
          ..close();
      case SpeechBubbleTail.bottomLeft:
        return Path()
          ..moveTo(40, size.height - 10)
          ..lineTo(56, size.height)
          ..lineTo(67, size.height - 10)
          ..close();
      case SpeechBubbleTail.none:
        return null;
    }
  }

  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) {
    return oldDelegate.tail != tail ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor;
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
    this.mascotSize = 156,
    this.maxBubbleWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: math.max(mascotSize, maxBubbleWidth),
      height: mascotSize + 96,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            child: AnimatedMascot(size: mascotSize, mood: mood),
          ),
          Positioned(
            top: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: SpeechBubble(
                text: message,
                tail: SpeechBubbleTail.bottomLeft,
              ),
            ),
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
    final color = selected ? MascotFlowTheme.active : MascotFlowTheme.border;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? MascotFlowTheme.surfaceAlt : MascotFlowTheme.bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 62),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color, width: selected ? 2.4 : 2),
            ),
            child: Row(
              children: [
                Icon(icon, color: selected ? MascotFlowTheme.active : color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: selected
                              ? MascotFlowTheme.active
                              : MascotFlowTheme.text,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: MascotFlowTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
          backgroundColor: AppTheme.cta,
          disabledBackgroundColor: MascotFlowTheme.border,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MascotFlowTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MascotFlowTheme.border, width: 2),
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
                    color: MascotFlowTheme.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${(value * 100).clamp(0, 100).round()}%',
                style: const TextStyle(
                  color: MascotFlowTheme.active,
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
              minHeight: 10,
              backgroundColor: const Color(0xFF0B171C),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cta),
            ),
          ),
        ],
      ),
    );
  }
}
