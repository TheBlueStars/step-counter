import 'dart:math' as math;

import 'package:flutter/material.dart';

class PieProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const PieProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawOval(rect.deflate(strokeWidth / 2), track);

    if (progress <= 0) {
      return;
    }

    final fill = Paint()..color = color;
    canvas.drawArc(
      rect.deflate(strokeWidth),
      0,
      2 * math.pi * progress.clamp(0.0, 1.0),
      true,
      fill,
    );
  }

  @override
  bool shouldRepaint(PieProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
