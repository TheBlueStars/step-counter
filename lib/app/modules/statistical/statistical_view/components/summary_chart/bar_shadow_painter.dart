import 'package:flutter/material.dart';

import 'chart_geometry.dart';

class BarShadowPainter extends CustomPainter {
  final List<double> values;
  final ChartGeometry geometry;
  final double topRadius;
  final double blurSigma;
  final List<Color> colorsShadow;

  const BarShadowPainter({
    required this.values,
    required this.geometry,
    required this.topRadius,
    required this.blurSigma,
    required this.colorsShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (geometry.isEmpty) {
      return;
    }

    final paint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value <= 0 || i >= colorsShadow.length) {
        continue;
      }

      paint.color = colorsShadow[i];
      final top = geometry.topY(value);
      final rect = Rect.fromLTWH(
        geometry.barLeft(i),
        top,
        geometry.barWidth,
        geometry.plotHeight - top,
      );
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(topRadius),
        topRight: Radius.circular(topRadius),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(BarShadowPainter oldDelegate) =>
      oldDelegate.geometry != geometry ||
      oldDelegate.colorsShadow != colorsShadow ||
      oldDelegate.values != values;
}
