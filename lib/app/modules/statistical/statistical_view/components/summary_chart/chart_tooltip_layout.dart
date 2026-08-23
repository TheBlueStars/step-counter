import 'dart:math' show max;
import 'dart:ui' show Size;

import 'chart_geometry.dart';

enum ChartTooltipArrow { left, center, right }

class ChartTooltipLayout {
  final double left;
  final double top;
  final double width;
  final double bodyHeight;
  final double arrowX;
  final double arrowHeight;
  final double halfArrow;
  final double radius;
  final ChartTooltipArrow arrow;

  const ChartTooltipLayout({
    required this.left,
    required this.top,
    required this.width,
    required this.bodyHeight,
    required this.arrowX,
    required this.arrowHeight,
    required this.halfArrow,
    required this.radius,
    required this.arrow,
  });

  factory ChartTooltipLayout.resolve({
    required ChartGeometry geometry,
    required int index,
    required double value,
    required Size textSize,
  }) {
    const hPad = 12.0;
    const vPad = 6.0;
    const arrowHeight = 6.0;
    const halfArrow = 6.0;
    const gapAbove = 6.0;
    const radius = 4.0;

    final centerX = geometry.barCenterX(index);
    final topY = geometry.topY(value);

    final width = (textSize.width + hPad * 2)
        .clamp(0.0, geometry.plotWidth)
        .toDouble();
    final bodyHeight = textSize.height + vPad * 2;

    final minLeft = geometry.leftInset;
    final maxLeft = geometry.size.width - width;
    final upperLeft = max(minLeft, maxLeft);
    final left = (centerX - width / 2).clamp(minLeft, upperLeft).toDouble();

    const arrowInset = halfArrow;
    final arrowRight = max(arrowInset, width - arrowInset);

    final arrow = index == 0
        ? ChartTooltipArrow.left
        : index == geometry.count - 1
        ? ChartTooltipArrow.right
        : ChartTooltipArrow.center;

    final arrowX = switch (arrow) {
      ChartTooltipArrow.left => arrowInset,
      ChartTooltipArrow.right => arrowRight,
      ChartTooltipArrow.center => (centerX - left)
          .clamp(arrowInset, arrowRight)
          .toDouble(),
    };

    return ChartTooltipLayout(
      left: left,
      top: (topY - gapAbove - arrowHeight - bodyHeight)
          .clamp(0.0, double.infinity)
          .toDouble(),
      width: width,
      bodyHeight: bodyHeight,
      arrowX: arrowX,
      arrowHeight: arrowHeight,
      halfArrow: halfArrow,
      radius: radius,
      arrow: arrow,
    );
  }
}
