import 'package:flutter/material.dart';
import 'package:project/app/data/models/enums/activity_metrics.dart';
import 'package:project/app/data/models/enums/bar_state.dart';
import 'package:project/app/data/models/enums/day_session.dart';
import 'package:project/app/data/models/enums/period_type.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

class SummaryChartLegend extends StatelessWidget {
  final PeriodType period;
  final ActivityMetrics metric;

  const SummaryChartLegend({
    super.key,
    required this.period,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final entries = period == PeriodType.day
        ? DaySession.values.map((s) => (color: s.color, label: s.label))
        : BarState.values
              .where(
                (s) => s != BarState.done || metric == ActivityMetrics.steps,
              )
              .map((s) => (color: s.colors[1], label: s.label));

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: entries
          .map((entry) => _legendItem(entry.color, entry.label))
          .toList(),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: 6),
        TnmText.description(label).copyWith(color: ColorName.neutralGray),
      ],
    );
  }
}
