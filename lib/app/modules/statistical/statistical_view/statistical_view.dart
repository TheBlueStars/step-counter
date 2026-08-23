import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/data/models/enums/activity_metrics.dart';
import 'package:project/app/routes/app_pages.dart';
import 'package:project/app/widgets/calendar/date_period_widget.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';
import 'package:project/generated/text_styles.gen.dart';

import '../../../../generated/assets.gen.dart';
import '../../../../generated/colors.gen.dart';
import '../../../widgets/default/app_bar_default.dart';
import '../../../widgets/default/page_default.dart';
import '../statistical_controller/statistical_controller.dart';
import 'components/metric_value_card.dart';
import 'components/summary_cards_grid.dart';
import 'components/summary_chart.dart';
import 'components/summary_status_card.dart';

class StatisticalView extends GetView<StatisticalController> {
  const StatisticalView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    final isOwnRoute =
        ModalRoute.of(context)?.settings.name == Routes.STATISTICAL;
    return PageDefault(
      appBar: AppBarDefault(
        middle: Center(
          child: !isOwnRoute
              ? TnmText.h5(
                  "Statistical",
                ).bold.copyWith(color: ColorName.neutralBlack)
              : ScaleTapWidget(
                  onTap: () => _chooseMetric(context, controller),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: ColorName.neutralWhite,
                      border: Border.all(color: ColorName.borderBackground),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Obx(
                          () => TnmText.title(
                            controller.selectedMetric.name,
                          ).semiBold.copyWith(color: ColorName.neutralBlack),
                        ),
                        Assets.svg.icLineChange.svg(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Obx(
              () => DatePeriodWidget(
                selectedPeriod: controller.period,
                dateLabel: controller.dateLabel,
                isAtCurrent: controller.isAtCurrent,
                onPeriodChanged: controller.changePeriod,
                onPrevious: controller.previousPeriod,
                onNext: controller.nextPeriod,
                onReturn: controller.resetToCurrent,
              ),
            ),

            ..._buildSections(controller: controller, isOwnRoute: isOwnRoute),

            SizedBox(height: 20),
          ],
        ).paddingSymmetric(horizontal: 16),
      ),
    );
  }

  Future<void> _chooseMetric(
    BuildContext context,
    StatisticalController controller,
  ) async {
    final selected = await showModalBottomSheet<ActivityMetrics>(
      context: context,
      backgroundColor: ColorName.neutralWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ActivityMetrics.values
              .map(
                (metric) => ListTile(
                  title: TnmText.body(metric.name),
                  trailing: metric == controller.selectedMetric
                      ? Icon(Icons.check_rounded, color: ColorName.primary100)
                      : null,
                  onTap: () => Navigator.of(context).pop(metric),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (selected != null) {
      controller.selectMetric(selected);
    }
  }

  List<Widget> _buildSections({
    required StatisticalController controller,
    required bool isOwnRoute,
  }) {
    if (isOwnRoute) {
      return _buildChartSection(controller);
    }

    return _buildMetricCards(controller);
  }

  List<Widget> _buildChartSection(StatisticalController controller) {
    return [
      Obx(() {
        final metric = controller.selectedMetric;
        return SummaryStatusCard(
          metric: metric,
          period: controller.period,
          totalValue: controller.totalValue,
          avgValue: controller.avgValue,
          totalTextColor: metric.totalTextColor,
          ellipseColor: metric.ellipseColor,
          totalBorderColors: metric.totalBorderColors,
        );
      }),
      Obx(
        () => SummaryChart(
          bars: controller.chartBars,
          totalStep: controller.totalStep,
          average: controller.chartAverage,
          period: controller.period,
          metric: controller.selectedMetric,
        ),
      ),
      Obx(() => SummaryCardsGrid(cards: controller.summaryCards)),
    ];
  }

  List<Widget> _buildMetricCards(StatisticalController controller) {
    return ActivityMetrics.values
        .map<Widget>(
          (metric) => Obx(
            () => MetricValueCard(
              title: metric.name,
              value: controller.totalValueOf(metric),
              subtitle: metric.totalSubtitle(controller.period),
              action: const Icon(Icons.navigate_next_rounded),
              borderColors: metric.totalBorderColors,
              iconWidgetMetric: metric.icon.image(width: 52, height: 52),
              onTap: () => controller.selectMetric(metric),
            ),
          ),
        )
        .toList();
  }
}
