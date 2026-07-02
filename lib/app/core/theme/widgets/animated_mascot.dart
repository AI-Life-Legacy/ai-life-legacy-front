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
      duration: const Duration(seconds: 12),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == oldWidget.animate) return;
    widget.animate ? _controller.repeat() : _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!widget.animate || reduceMotion) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(painter: _NpcPainter(mood: widget.mood)),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pose = _MascotPose.fromMood(
          mood: widget.mood,
          phase: _controller.value,
        );
        return Transform.translate(
          offset: Offset(0, widget.size * pose.yOffset),
          child: Transform.rotate(
            angle: pose.rotation,
            child: Transform.scale(
              scaleX: pose.scaleX,
              scaleY: pose.scaleY,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _NpcPainter(
                    mood: widget.mood,
                    phase: _controller.value,
                    blink: pose.blink,
                    eyeShift: pose.eyeShift,
                    mouthOpen: pose.mouthOpen,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MascotPose {
  final double yOffset;
  final double rotation;
  final double scaleX;
  final double scaleY;
  final double blink;
  final double eyeShift;
  final double mouthOpen;

  const _MascotPose({
    required this.yOffset,
    required this.rotation,
    required this.scaleX,
    required this.scaleY,
    required this.blink,
    required this.eyeShift,
    required this.mouthOpen,
  });

  factory _MascotPose.fromMood({
    required MascotMood mood,
    required double phase,
  }) {
    final breath = math.sin(phase * math.pi * 8);
    final action = _windowPulse(phase, 0.64, 0.82);
    final actionProgress = _windowProgress(phase, 0.64, 0.82);
    final blink = math.max(
      _windowPulse(phase, 0.18, 0.205),
      _windowPulse(phase, 0.47, 0.495),
    );

    switch (mood) {
      case MascotMood.success:
        final hop = math.sin(actionProgress * math.pi * 4).clamp(0.0, 1.0);
        return _MascotPose(
          yOffset: -0.014 * breath - 0.075 * hop,
          rotation: math.sin(actionProgress * math.pi * 6) * 0.08,
          scaleX: 1 + hop * 0.045,
          scaleY: 1 - hop * 0.035,
          blink: 0,
          eyeShift: 0,
          mouthOpen: 1,
        );
      case MascotMood.sad:
        final sigh = math.sin(action * math.pi).clamp(0.0, 1.0);
        return _MascotPose(
          yOffset: 0.016 + 0.006 * breath + 0.028 * sigh,
          rotation: -0.045 + math.sin(action * math.pi * 5) * 0.018,
          scaleX: 0.99,
          scaleY: 1.01 + sigh * 0.025,
          blink: blink * 0.8,
          eyeShift: 0,
          mouthOpen: 0,
        );
      case MascotMood.thinking:
        final lookAround = math.sin(actionProgress * math.pi * 2);
        return _MascotPose(
          yOffset: -0.012 * breath,
          rotation: 0.035 + lookAround * 0.035,
          scaleX: 1 + breath * 0.006,
          scaleY: 1 - breath * 0.008,
          blink: blink,
          eyeShift: lookAround * 7,
          mouthOpen: 0.15,
        );
      case MascotMood.listening:
        final pulse = math.sin(actionProgress * math.pi * 5).clamp(0.0, 1.0);
        return _MascotPose(
          yOffset: -0.012 * breath,
          rotation: -0.035 - pulse * 0.035,
          scaleX: 1 + pulse * 0.035,
          scaleY: 1 - pulse * 0.018,
          blink: blink,
          eyeShift: -pulse * 3,
          mouthOpen: 0.25,
        );
      case MascotMood.idle:
        final spin = Curves.easeInOut.transform(actionProgress);
        return _MascotPose(
          yOffset: -0.016 * breath,
          rotation: spin * math.pi * 2 + breath * 0.018,
          scaleX: 1 + breath * 0.008,
          scaleY: 1 - breath * 0.01,
          blink: blink,
          eyeShift: 0,
          mouthOpen: 0.45,
        );
    }
  }

  static double _windowProgress(double value, double start, double end) {
    if (value <= start || value >= end) return 0;
    return ((value - start) / (end - start)).clamp(0.0, 1.0);
  }

  static double _windowPulse(double value, double start, double end) {
    final local = _windowProgress(value, start, end);
    if (local == 0) return 0;
    return math.sin(local * math.pi);
  }
}

class _NpcPainter extends CustomPainter {
  final MascotMood mood;
  final double phase;
  final double blink;
  final double eyeShift;
  final double mouthOpen;

  const _NpcPainter({
    required this.mood,
    this.phase = 0,
    this.blink = 0,
    this.eyeShift = 0,
    this.mouthOpen = 0.45,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - shortest) / 2, (size.height - shortest) / 2);
    canvas.scale(shortest / 220);

    final bob = math.sin(phase * math.pi * 2) * 4;
    canvas.translate(0, bob);
    _drawCharacter(canvas);
    canvas.restore();
  }

  void _drawCharacter(Canvas canvas) {
    _drawShadow(canvas);
    switch (mood) {
      case MascotMood.idle:
        _drawTriangleBody(canvas, AppTheme.sky);
        break;
      case MascotMood.success:
        _drawSquareBody(canvas, AppTheme.cta);
        break;
      case MascotMood.thinking:
        _drawCloudBody(canvas, AppTheme.sun);
        break;
      case MascotMood.listening:
        _drawCapsuleBody(canvas, AppTheme.coral);
        break;
      case MascotMood.sad:
        _drawDiamondBody(canvas, AppTheme.lavender);
        break;
    }
    _drawEyes(canvas);
    _drawMouth(canvas);
  }

  void _drawShadow(Canvas canvas) {
    canvas.drawOval(
      const Rect.fromLTWH(58, 170, 104, 14),
      Paint()..color = AppTheme.shadow.withValues(alpha: 0.16),
    );
  }

  void _drawTriangleBody(Canvas canvas, Color color) {
    _drawTriangle(
      canvas,
      const Offset(110, 28),
      const Offset(182, 158),
      const Offset(38, 158),
      color,
    );
  }

  void _drawSquareBody(Canvas canvas, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 46, 124, 124),
        const Radius.circular(18),
      ),
      Paint()..color = color,
    );
  }

  void _drawCloudBody(Canvas canvas, Color color) {
    final paint = Paint()..color = color;
    for (final circle in const [
      Rect.fromLTWH(44, 80, 48, 48),
      Rect.fromLTWH(72, 54, 58, 58),
      Rect.fromLTWH(116, 70, 56, 56),
      Rect.fromLTWH(82, 96, 64, 64),
    ]) {
      canvas.drawOval(circle, paint);
    }
  }

  void _drawCapsuleBody(Canvas canvas, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 62, 132, 92),
        const Radius.circular(46),
      ),
      Paint()..color = color,
    );
  }

  void _drawDiamondBody(Canvas canvas, Color color) {
    _drawTriangle(
      canvas,
      const Offset(110, 26),
      const Offset(188, 102),
      const Offset(110, 178),
      color,
    );
    _drawTriangle(
      canvas,
      const Offset(110, 26),
      const Offset(110, 178),
      const Offset(32, 102),
      color,
    );
  }

  void _drawTriangle(
    Canvas canvas,
    Offset a,
    Offset b,
    Offset c,
    Color color,
  ) {
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..close(),
      Paint()..color = color,
    );
  }

  void _drawEyes(Canvas canvas) {
    switch (mood) {
      case MascotMood.idle:
        _drawOvalEyes(canvas, 88, 98);
        break;
      case MascotMood.success:
        _drawDotEyes(canvas, 88, 98);
        break;
      case MascotMood.thinking:
        _drawSleepyEyes(canvas, 88, 104);
        break;
      case MascotMood.listening:
        _drawTallEyes(canvas, 88, 100);
        break;
      case MascotMood.sad:
        _drawDowncastEyes(canvas, 88, 96);
        break;
    }
  }

  void _drawOvalEyes(Canvas canvas, double leftX, double y) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = AppTheme.text;
    final eyeHeight = (34 * (1 - blink * 0.82)).clamp(5.0, 34.0);
    final pupilHeight = (32 * (1 - blink * 0.92)).clamp(3.0, 32.0);
    for (final x in [leftX, leftX + 44]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + eyeShift, y),
          width: 28,
          height: eyeHeight,
        ),
        eyePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 3 + eyeShift, y),
          width: 11,
          height: pupilHeight,
        ),
        pupilPaint,
      );
    }
  }

  void _drawTallEyes(Canvas canvas, double leftX, double y) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = AppTheme.text;
    final eyeHeight = (48 * (1 - blink * 0.82)).clamp(5.0, 48.0);
    final pupilHeight = (46 * (1 - blink * 0.92)).clamp(3.0, 46.0);
    for (final x in [leftX, leftX + 44]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + eyeShift, y),
          width: 24,
          height: eyeHeight,
        ),
        eyePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 2 + eyeShift, y),
          width: 11,
          height: pupilHeight,
        ),
        pupilPaint,
      );
    }
  }

  void _drawDotEyes(Canvas canvas, double leftX, double y) {
    final paint = Paint()..color = AppTheme.text;
    final height = (16 * (1 - blink * 0.84)).clamp(3.0, 16.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftX + eyeShift, y),
        width: 16,
        height: height,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftX + 44 + eyeShift, y),
        width: 16,
        height: height,
      ),
      paint,
    );
  }

  void _drawSleepyEyes(Canvas canvas, double leftX, double y) {
    final paint = Paint()..color = AppTheme.text;
    _drawTriangle(
      canvas,
      Offset(leftX - 15, y - 5),
      Offset(leftX + 15, y - 5),
      Offset(leftX, y + 11),
      paint.color,
    );
    _drawTriangle(
      canvas,
      Offset(leftX + 29, y - 5),
      Offset(leftX + 59, y - 5),
      Offset(leftX + 44, y + 11),
      paint.color,
    );
  }

  void _drawDowncastEyes(Canvas canvas, double leftX, double y) {
    final paint = Paint()
      ..color = AppTheme.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX - 12, y - 7), Offset(leftX + 12, y + 4), paint);
    canvas.drawLine(
      Offset(leftX + 32, y + 4),
      Offset(leftX + 56, y - 7),
      paint,
    );
  }

  void _drawMouth(Canvas canvas) {
    final paint = Paint()
      ..color = AppTheme.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path();
    if (mood == MascotMood.sad) {
      path
        ..moveTo(96, 128)
        ..quadraticBezierTo(110, 122, 124, 128);
    } else {
      final smileDepth = 8 + mouthOpen * 7;
      path
        ..moveTo(96, 122)
        ..quadraticBezierTo(110, 122 + smileDepth, 124, 122);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NpcPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.phase != phase ||
        oldDelegate.blink != blink ||
        oldDelegate.eyeShift != eyeShift ||
        oldDelegate.mouthOpen != mouthOpen;
  }
}
