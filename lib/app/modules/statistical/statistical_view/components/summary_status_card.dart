import 'package:flutter/material.dart';
import 'package:project/app/data/models/enums/activity_metrics.dart';
import 'package:project/app/data/models/enums/period_type.dart';

import 'metric_value_card.dart';

class SummaryStatusCard extends StatelessWidget {
  final ActivityMetrics metric;
  final PeriodType period;
  final String totalValue;
  final String avgValue;
  final Color totalTextColor;
  final Color ellipseColor;
  final List<Color> totalBorderColors;
  const SummaryStatusCard({
    super.key,
    required this.metric,
    required this.period,
    required this.totalValue,
    required this.avgValue,
    required this.totalTextColor,
    required this.ellipseColor,
    required this.totalBorderColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: MetricValueCard(
            title: "TOTAL ${metric.name.toUpperCase()}",
            value: totalValue,
            subtitle: metric.totalSubtitle(period),
            textColor: totalTextColor,
            ellipseColor: ellipseColor,
            borderColors: totalBorderColors,
          ),
        ),
        Expanded(
          child: MetricValueCard(
            title: metric.avgTitle(period),
            value: avgValue,
            subtitle: metric.activeSubtitle(period),
          ),
        ),
      ],
    );
  }
}
