import 'dart:math' as math;

import 'package:ai_life_legacy/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum MascotMood {
  idle,
  success,
  sad,
  thinking,
  listening,
}

class AnimatedMascot extends StatefulWidget {
  final double size;
  final bool animate;
  final MascotMood mood;

  const AnimatedMascot({
    super.key,
    required this.size,
    this.animate = true,
    this.mood = MascotMood.idle,
  });

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == oldWidget.animate) return;

    if (widget.animate) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final shouldAnimate = widget.animate && !reduceMotion;

    if (!shouldAnimate) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(painter: _OrbMascotPainter(mood: widget.mood)),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final cycle = _controller.value * math.pi * 2;
        final wave = math.sin(cycle);
        final settle = math.cos(cycle);
        final breath = (wave + 1) / 2;
        final blink = _blinkAmount(_controller.value);
        final state = _MascotMotion.fromMood(
          mood: widget.mood,
          value: _controller.value,
          wave: wave,
          settle: settle,
        );

        return Transform.translate(
          offset: Offset(0, widget.size * state.yOffset),
          child: Transform.scale(
            scaleX: state.scaleX,
            scaleY: state.scaleY,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _OrbMascotPainter(
                  mood: widget.mood,
                  breath: breath,
                  blink: blink,
                  armWave: state.armWave,
                  eyeShift: state.eyeShift,
                  mouthOpen: state.mouthOpen,
                  lean: state.lean,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _blinkAmount(double value) {
    if (widget.mood == MascotMood.success) return 0;
    if (value < 0.78 || value > 0.88) return 0;
    final local = (value - 0.78) / 0.10;
    return math.sin(local * math.pi);
  }
}

class _MascotMotion {
  final double yOffset;
  final double scaleX;
  final double scaleY;
  final double armWave;
  final double eyeShift;
  final double mouthOpen;
  final double lean;

  const _MascotMotion({
    required this.yOffset,
    required this.scaleX,
    required this.scaleY,
    required this.armWave,
    required this.eyeShift,
    required this.mouthOpen,
    required this.lean,
  });

  factory _MascotMotion.fromMood({
    required MascotMood mood,
    required double value,
    required double wave,
    required double settle,
  }) {
    switch (mood) {
      case MascotMood.success:
        final hop = math.sin(value * math.pi * 4).clamp(0.0, 1.0);
        return _MascotMotion(
          yOffset: -0.038 * hop,
          scaleX: 1 + (settle * 0.016),
          scaleY: 1 - (settle * 0.022),
          armWave: math.sin(value * math.pi * 6),
          eyeShift: 0,
          mouthOpen: 1,
          lean: wave * 0.03,
        );
      case MascotMood.sad:
        return _MascotMotion(
          yOffset: 0.018 + (wave * 0.004),
          scaleX: 0.985,
          scaleY: 1.015,
          armWave: -0.5,
          eyeShift: 0,
          mouthOpen: 0,
          lean: -0.05,
        );
      case MascotMood.thinking:
        return _MascotMotion(
          yOffset: -0.008 * wave,
          scaleX: 1 + (settle * 0.008),
          scaleY: 1 - (settle * 0.012),
          armWave: 0.15,
          eyeShift: math.sin(value * math.pi * 2) * 4,
          mouthOpen: 0.2,
          lean: 0.04,
        );
      case MascotMood.listening:
        return _MascotMotion(
          yOffset: -0.01 * wave,
          scaleX: 1 + (settle * 0.01),
          scaleY: 1 - (settle * 0.014),
          armWave: 0,
          eyeShift: math.sin(value * math.pi * 2) * 2,
          mouthOpen: 0,
          lean: -0.025,
        );
      case MascotMood.idle:
        return _MascotMotion(
          yOffset: -0.014 * wave,
          scaleX: 1 + (settle * 0.012),
          scaleY: 1 - (settle * 0.018),
          armWave: wave * 0.12,
          eyeShift: 0,
          mouthOpen: 0.45,
          lean: 0,
        );
    }
  }
}

class _OrbMascotPainter extends CustomPainter {
  final MascotMood mood;
  final double breath;
  final double blink;
  final double armWave;
  final double eyeShift;
  final double mouthOpen;
  final double lean;

  const _OrbMascotPainter({
    this.mood = MascotMood.idle,
    this.breath = 0,
    this.blink = 0,
    this.armWave = 0,
    this.eyeShift = 0,
    this.mouthOpen = 0.45,
    this.lean = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final scale = shortest / 300;
    canvas.save();
    canvas.translate((size.width - shortest) / 2, (size.height - shortest) / 2);
    canvas.scale(scale);

    canvas.save();
    canvas.translate(150, 145);
    canvas.rotate(lean);
    canvas.translate(-150, -145);
    _drawGlow(canvas);
    _drawShadow(canvas);
    _drawHalo(canvas);
    _drawOrb(canvas);
    _drawSparkles(canvas);
    _drawEyes(canvas);
    _drawMouth(canvas);
    canvas.restore();

    canvas.restore();
  }

  void _drawShadow(Canvas canvas) {
    final paint = Paint()
      ..color = AppTheme.skyDark.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(150, 236),
        width: 116 + (breath * 14),
        height: 19,
      ),
      paint,
    );
  }

  void _drawGlow(Canvas canvas) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _accentColor.withValues(alpha: 0.34 + breath * 0.08),
          _accentColor.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: const Offset(150, 140),
          radius: 116 + breath * 10,
        ),
      );
    canvas.drawCircle(
      const Offset(150, 140),
      116 + breath * 10,
      glowPaint,
    );
  }

  void _drawHalo(Canvas canvas) {
    final haloPaint = Paint()
      ..color = _accentColor.withValues(alpha: 0.16 + breath * 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: const Offset(150, 138),
        width: 150 + breath * 10,
        height: 150 + breath * 10,
      ),
      math.pi * 1.08,
      math.pi * 1.34,
      false,
      haloPaint,
    );
  }

  void _drawOrb(Canvas canvas) {
    final center = Offset(150, 140 - breath * 3);
    final radius = 70 + breath * 4;

    final orbPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.38, -0.48),
        radius: 0.95,
        colors: [
          Colors.white,
          _softColor,
          _accentColor,
        ],
        stops: const [0.0, 0.46, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, orbPaint);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(center.dx - 24, center.dy - 28),
      16,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.52)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(center.dx + 34, center.dy + 34),
      12,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSparkles(Canvas canvas) {
    final sparklePaint = Paint()
      ..color = _accentColor.withValues(alpha: 0.62)
      ..style = PaintingStyle.fill;

    _drawSparkle(
      canvas,
      Offset(76, 83 + armWave * 8),
      10 + breath * 2,
      sparklePaint,
    );
    _drawSparkle(
      canvas,
      Offset(226, 89 - armWave * 7),
      8 + breath * 2,
      sparklePaint..color = _softColor.withValues(alpha: 0.7),
    );
    _drawSparkle(
      canvas,
      Offset(222, 190 + armWave * 5),
      6 + breath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.78)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx + radius * 0.22, center.dy - radius * 0.22,
          center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx + radius * 0.22, center.dy + radius * 0.22,
          center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx - radius * 0.22, center.dy + radius * 0.22,
          center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx - radius * 0.22, center.dy - radius * 0.22,
          center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawEyes(Canvas canvas) {
    final eyePaint = Paint()
      ..color = const Color(0xFF183047)
      ..style = PaintingStyle.fill;
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final eyeHeight = (22 * (1 - blink * 0.8)).clamp(4.0, 22.0);
    final y = 129 - (breath * 3);
    final isSad = mood == MascotMood.sad;

    for (final x in const [124.0, 176.0]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(x + eyeShift * 0.45, y + (isSad ? 5 : 0)),
            width: 15,
            height: eyeHeight),
        eyePaint,
      );
      if (blink < 0.6) {
        canvas.drawCircle(
          Offset(x - 3 + eyeShift * 0.45, y - 5 + (isSad ? 5 : 0)),
          2.4,
          glintPaint,
        );
      }
    }
  }

  void _drawMouth(Canvas canvas) {
    final smilePaint = Paint()
      ..color = const Color(0xFF183047)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final y = 153 - (breath * 3);
    if (mood == MascotMood.sad) {
      final path = Path()
        ..moveTo(133, y + 10)
        ..quadraticBezierTo(150, y - 1, 167, y + 10);
      canvas.drawPath(path, smilePaint);
      return;
    }

    final smileDepth = mood == MascotMood.success ? 18.0 : 10 + mouthOpen * 5;
    final path = Path()
      ..moveTo(131, y)
      ..quadraticBezierTo(150, y + smileDepth, 169, y);
    canvas.drawPath(path, smilePaint);
  }

  Color get _accentColor {
    switch (mood) {
      case MascotMood.success:
        return AppTheme.cta;
      case MascotMood.sad:
        return AppTheme.lavender;
      case MascotMood.thinking:
        return AppTheme.sky;
      case MascotMood.listening:
        return AppTheme.sun;
      case MascotMood.idle:
        return AppTheme.sky;
    }
  }

  Color get _softColor {
    switch (mood) {
      case MascotMood.success:
        return const Color(0xFFC8F58D);
      case MascotMood.sad:
        return const Color(0xFFE9D7FF);
      case MascotMood.thinking:
        return const Color(0xFFC8F1FF);
      case MascotMood.listening:
        return const Color(0xFFFFE990);
      case MascotMood.idle:
        return const Color(0xFFD5F6FF);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbMascotPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.breath != breath ||
        oldDelegate.blink != blink ||
        oldDelegate.armWave != armWave ||
        oldDelegate.eyeShift != eyeShift ||
        oldDelegate.mouthOpen != mouthOpen ||
        oldDelegate.lean != lean;
  }
}
