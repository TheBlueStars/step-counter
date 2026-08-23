import 'package:project/generated/assets.gen.dart';

import 'enums/activity_metrics.dart';
import 'enums/period_type.dart';
import 'summary_card_data.dart';

class SummaryStatistical {
  final SummaryCardData peakTime;
  final SummaryCardData peakDay;
  final SummaryCardData peakMonth;
  final SummaryCardData quietDay;
  final SummaryCardData quietMonth;
  final SummaryCardData activeHours;
  final SummaryCardData longestStreak;
  final double goalProgress;
  final AssetGenImage goalIcon;

  const SummaryStatistical({
    required this.peakTime,
    required this.peakDay,
    required this.peakMonth,
    required this.quietDay,
    required this.quietMonth,
    required this.activeHours,
    required this.longestStreak,
    required this.goalProgress,
    required this.goalIcon,
  });

  List<SummaryCardData> cards(ActivityMetrics metric, PeriodType period) {
    final isSteps = metric == ActivityMetrics.steps;

    if (period.isDay) {
      if (isSteps) {
        return [peakTime, _goalCard(period)];
      }

      if (metric == ActivityMetrics.time) {
        return [peakTime, longestStreak];
      }

      return [peakTime, activeHours];
    }

    return [
      period.isYear ? peakMonth : peakDay,
      period.isYear ? quietMonth : quietDay,
      if (isSteps) ...[longestStreak, _goalCard(period)],
    ];
  }

  SummaryCardData _goalCard(PeriodType period) => SummaryCardData.goal(
    title: period.goalTitle,
    progress: goalProgress,
    icon: goalIcon,
  );
}
