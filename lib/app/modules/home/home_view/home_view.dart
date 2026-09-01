import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/modules/home/home_view/components/app_bar_home.dart';
import 'package:project/app/widgets/calendar/calendar_widget.dart';
import 'package:project/app/widgets/default/page_default.dart';

import '../home_controller/home_controller.dart';
import 'components/step_tracker_card.dart';
import 'components/week_step_chart.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    return PageDefault(
      appBar: Obx(
        () => AppBarHome(longStreak: controller.streakDays),
      ).paddingSymmetric(vertical: 16),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CalendarWidget(
              progressOf: controller.progressOf,
              onDaySelected: controller.onDaySelected,
              progressChangedDay: controller.progressChangedDay,
              selectDay: controller.selectDayRequest,
            ),
            SizedBox(height: 12),
            Obx(
              () => StepTrackerCard(
                steps: controller.steps,
                stepGoal: controller.stepGoal,
                calories: controller.calories,
                distance: controller.distanceKm,
                elapsedTime: controller.activeTime,
                isTracking: controller.isTracking,
                onTapEditGoal: controller.onTapEditGoal,
                onTapReset: controller.onTapReset,
                onTapEditStep: controller.onTapEditStep,
                onTapStats: controller.goToStatistical,
                onTapPlay: controller.onTapPlay,
              ),
            ),
            SizedBox(height: 16),
            Obx(
              () => WeekStepChart(
                bars: controller.weekBars,
                totalStep: controller.weekChartMax,
                average: controller.weekAverage,
                totalLabel: controller.weekTotalLabel,
                rangeLabel: controller.weekRangeLabel,
                onTapMore: controller.goToStatistical,
              ),
            ),
            SizedBox(height: 16),
          ],
        ).paddingSymmetric(horizontal: 16),
      ),
    );
  }
}
