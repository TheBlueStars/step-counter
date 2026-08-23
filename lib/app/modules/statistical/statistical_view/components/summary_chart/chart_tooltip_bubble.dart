import 'package:flutter/material.dart';

import 'chart_tooltip_layout.dart';

class ChartTooltipBubble extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color color;
  final ChartTooltipLayout layout;

  const ChartTooltipBubble({
    super.key,
    required this.text,
    required this.style,
    required this.color,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: layout.width,
      height: layout.bodyHeight + layout.arrowHeight,
      child: CustomPaint(
        painter: _BubblePainter(color: color, layout: layout),
        child: Padding(
          padding: EdgeInsets.only(bottom: layout.arrowHeight),
          child: Center(child: Text(text, style: style, maxLines: 1)),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final ChartTooltipLayout layout;

  const _BubblePainter({required this.color, required this.layout});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final r = Radius.circular(layout.radius);
    final roundBottom = layout.arrow == ChartTooltipArrow.center
        ? r
        : Radius.zero;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, layout.bodyHeight),
        topLeft: r,
        topRight: r,
        bottomLeft: roundBottom,
        bottomRight: roundBottom,
      ),
      paint,
    );

    canvas.drawPath(_arrowPath(), paint);
  }

  Path _arrowPath() {
    final baseY = layout.bodyHeight;
    final tipY = layout.bodyHeight + layout.arrowHeight;
    final half = layout.halfArrow;
    final x = layout.arrowX;

    switch (layout.arrow) {
      case ChartTooltipArrow.left:
        final edge = x - half;
        return Path()
          ..moveTo(edge, baseY)
          ..lineTo(edge + half * 2, baseY)
          ..lineTo(edge, tipY)
          ..close();
      case ChartTooltipArrow.right:
        final edge = x + half;
        return Path()
          ..moveTo(edge, baseY)
          ..lineTo(edge - half * 2, baseY)
          ..lineTo(edge, tipY)
          ..close();
      case ChartTooltipArrow.center:
        return Path()
          ..moveTo(x - half, baseY)
          ..lineTo(x + half, baseY)
          ..lineTo(x, tipY)
          ..close();
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.color != color ||
      old.layout.arrow != layout.arrow ||
      old.layout.arrowX != layout.arrowX ||
      old.layout.arrowHeight != layout.arrowHeight ||
      old.layout.halfArrow != layout.halfArrow ||
      old.layout.bodyHeight != layout.bodyHeight ||
      old.layout.radius != layout.radius;
}
