import 'dart:ui' show Size;

class ChartGeometry {
  final Size size;
  final int count;
  final double barWidth;
  final double maxY;
  final double leftInset;
  final double bottomInset;

  const ChartGeometry({
    required this.size,
    required this.count,
    required this.barWidth,
    required this.maxY,
    required this.leftInset,
    required this.bottomInset,
  });

  double get plotWidth => size.width - leftInset;

  double get plotHeight => size.height - bottomInset;

  bool get isEmpty =>
      count == 0 || maxY <= 0 || plotWidth <= 0 || plotHeight <= 0;

  double get gap =>
      count > 1 ? (plotWidth - count * barWidth) / (count - 1) : 0.0;

  double barLeft(int index) => leftInset + index * (barWidth + gap);

  double barCenterX(int index) => barLeft(index) + barWidth / 2;

  double topY(double value) =>
      plotHeight - (value / maxY).clamp(0.0, 1.0) * plotHeight;

  @override
  bool operator ==(Object other) =>
      other is ChartGeometry &&
      other.size == size &&
      other.count == count &&
      other.barWidth == barWidth &&
      other.maxY == maxY &&
      other.leftInset == leftInset &&
      other.bottomInset == bottomInset;

  @override
  int get hashCode =>
      Object.hash(size, count, barWidth, maxY, leftInset, bottomInset);
}
