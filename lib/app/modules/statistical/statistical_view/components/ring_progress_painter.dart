import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RingProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final List<Color>? gradientColors;

  const RingProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    this.gradientColors,
  });

  static const double _startAngle = math.pi / 2;
  static const double _totalSweep = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, _totalSweep, false, track);

    if (progress <= 0) {
      return;
    }

    final sweep = _totalSweep * progress.clamp(0.0, 1.0);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final colors = gradientColors;
    if (colors != null && colors.length >= 2) {
      final capAngle = strokeWidth / rect.width;
      arc.shader = SweepGradient(
        startAngle: 0,
        endAngle: math.max(sweep + capAngle, 0.01),
        colors: colors,
        transform: GradientRotation(_startAngle - capAngle),
      ).createShader(rect);
    } else {
      arc.color = color;
    }

    canvas.drawArc(rect, _startAngle, sweep, false, arc);
  }

  @override
  bool shouldRepaint(RingProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      !listEquals(oldDelegate.gradientColors, gradientColors);
}
