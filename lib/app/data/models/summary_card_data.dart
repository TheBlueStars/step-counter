import 'package:project/generated/assets.gen.dart';

class SummaryCardData {
  final String title;
  final String value;
  final String subtitle;
  final double? progress;
  final AssetGenImage icon;

  const SummaryCardData.stat({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle = '',
  }) : progress = null;

  const SummaryCardData.goal({
    required this.title,
    required this.progress,
    required this.icon,
  }) : value = '',
       subtitle = '';

  bool get isGoal => progress != null;
}
