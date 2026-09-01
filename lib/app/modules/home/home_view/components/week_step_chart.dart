import 'package:flutter/material.dart';
import 'package:project/app/data/models/chart_bar.dart';
import 'package:project/app/data/models/enums/activity_metrics.dart';
import 'package:project/app/data/models/enums/period_type.dart';
import 'package:project/app/modules/statistical/statistical_view/components/summary_chart.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

class WeekStepChart extends StatelessWidget {
  final List<ChartBar> bars;
  final int totalStep;
  final double average;
  final String totalLabel;
  final String rangeLabel;
  final VoidCallback? onTapMore;

  const WeekStepChart({
    super.key,
    required this.bars,
    required this.totalStep,
    required this.average,
    required this.totalLabel,
    required this.rangeLabel,
    this.onTapMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 12),
        SummaryChart(
          bars: bars,
          totalStep: totalStep,
          average: average,
          period: PeriodType.week,
          metric: ActivityMetrics.steps,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TnmText.title(
                "This week",
              ).semiBold.copyWith(color: ColorName.neutralBlack),
              SizedBox(height: 2),
              TnmText.description(
                rangeLabel,
              ).copyWith(color: ColorName.neutralGray),
            ],
          ),
        ),
        ScaleTapWidget(
          onTap: onTapMore,
          child: Row(
            children: [
              TnmText.body(
                totalLabel,
              ).semiBold.copyWith(color: ColorName.primary100),
              Icon(
                Icons.navigate_next_rounded,
                size: 20,
                color: ColorName.primary100,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
