import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GaugeProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  final List<Color>? gradientColors;
  final Color? shadowColor;

  const GaugeProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    this.gradientColors,
    this.shadowColor,
  });

  static const double _startAngle = 3 * math.pi / 4;
  static const double _totalSweep = 3 * math.pi / 2;

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

    final shadow = shadowColor;
    if (shadow != null) {
      final shadowPaint = Paint()
        ..color = shadow
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth / 3);
      canvas.drawArc(
        rect.shift(Offset(0, strokeWidth / 5)),
        _startAngle,
        sweep,
        false,
        shadowPaint,
      );
    }

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
  bool shouldRepaint(GaugeProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.shadowColor != shadowColor ||
      !listEquals(oldDelegate.gradientColors, gradientColors);
}
