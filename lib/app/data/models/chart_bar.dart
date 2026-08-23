class ChartBar {
  final double value;
  final String label;
  final String tooltip;
  final bool isCurrent;
  final bool isDone;
  final bool isFuture;

  const ChartBar({
    required this.value,
    required this.label,
    this.tooltip = "",
    this.isCurrent = false,
    this.isDone = false,
    this.isFuture = false,
  });

  bool get hasData => value > 0;
}
