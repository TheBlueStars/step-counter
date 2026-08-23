import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:project/app/extensions/number_extension.dart';
import 'package:project/app/utils/step_metrics_utils.dart';
import 'package:project/generated/assets.gen.dart';
import 'package:project/generated/colors.gen.dart';

import '../chart_bar.dart';
import 'period_type.dart';

enum ActivityMetrics {
  steps,
  calories,
  distance,
  time;

  String get name => switch (this) {
    ActivityMetrics.steps => "Steps",
    ActivityMetrics.calories => "Calories",
    ActivityMetrics.distance => "Distance",
    ActivityMetrics.time => "Time",
  };

  String avgTitle(PeriodType period) => switch ((this, period)) {
    (ActivityMetrics.time, PeriodType.day) => "ACTIVE TIME",

    (
      ActivityMetrics.steps || .calories || .distance || .time,
      PeriodType.week,
    ) =>
      "DAILY AVG",
    (
      ActivityMetrics.steps || .calories || .distance || .time,
      PeriodType.year,
    ) =>
      "MONTHLY AVG",

    (_, _) => "ACTIVE HOUR AVG",
  };

  String totalSubtitle(PeriodType period) => switch ((this, period)) {
    (ActivityMetrics.steps, PeriodType.day) => "steps today",
    (ActivityMetrics.steps, PeriodType.week) => "steps this week",
    (ActivityMetrics.steps, PeriodType.month) => "steps this month",
    (ActivityMetrics.steps, PeriodType.year) => "steps this year",
    (ActivityMetrics.calories, PeriodType.day) => "kcal burned today",
    (ActivityMetrics.calories, PeriodType.week) => "kcal burned this week",
    (ActivityMetrics.calories, PeriodType.month) => "kcal burned this month",
    (ActivityMetrics.calories, PeriodType.year) => "kcal burned this year",
    (ActivityMetrics.distance, PeriodType.day) => "kilometers today",
    (ActivityMetrics.distance, PeriodType.week) => "kilometers this week",
    (ActivityMetrics.distance, PeriodType.month) => "kilometers this month",
    (ActivityMetrics.distance, PeriodType.year) => "kilometers this year",
    (ActivityMetrics.time, PeriodType.day) => "minutes today",
    (ActivityMetrics.time, PeriodType.week) => "minutes this week",
    (ActivityMetrics.time, PeriodType.month) => "minutes this month",
    (ActivityMetrics.time, PeriodType.year) => "minutes this year",
  };

  String activeSubtitle(PeriodType period) => switch ((this, period)) {
    (ActivityMetrics.steps, PeriodType.day) => "steps per active hour",
    (ActivityMetrics.steps, PeriodType.week) => "steps per day",
    (ActivityMetrics.steps, PeriodType.month) => "steps per day",
    (ActivityMetrics.steps, PeriodType.year) => "steps per month",
    (ActivityMetrics.calories, PeriodType.day) => "kcal per active hour",
    (ActivityMetrics.calories, PeriodType.week) => "kcal per day",
    (ActivityMetrics.calories, PeriodType.month) => "kcal per day",
    (ActivityMetrics.calories, PeriodType.year) => "kcal per month",
    (ActivityMetrics.distance, PeriodType.day) => "kilometers per active hour",
    (ActivityMetrics.distance, PeriodType.week) => "kilometers per day",
    (ActivityMetrics.distance, PeriodType.month) => "kilometers per day",
    (ActivityMetrics.distance, PeriodType.year) => "kilometers per month",
    (ActivityMetrics.time, PeriodType.day) => "minutes with activity",
    (ActivityMetrics.time, PeriodType.week) => "minutes per day",
    (ActivityMetrics.time, PeriodType.month) => "minutes per day",
    (ActivityMetrics.time, PeriodType.year) => "minutes per month",
  };

  Color get totalTextColor => switch (this) {
    ActivityMetrics.steps => ColorName.primary100,
    ActivityMetrics.calories => ColorName.errorStatus,
    ActivityMetrics.distance => ColorName.infoStatus,
    ActivityMetrics.time => ColorName.successStatus,
  };

  List<Color> get totalBorderColors => switch (this) {
    ActivityMetrics.steps => ColorName.gradientBorderOrange.colors,
    ActivityMetrics.calories => ColorName.gradientBorderRed.colors,
    ActivityMetrics.distance => ColorName.gradientBorderBlue.colors,
    ActivityMetrics.time => ColorName.gradientBorderStatus.colors,
  };

  Color get ellipseColor => switch (this) {
    ActivityMetrics.steps => ColorName.primary20,
    ActivityMetrics.calories => ColorName.extra.extra2,
    ActivityMetrics.distance => ColorName.extra.extra3,
    ActivityMetrics.time => ColorName.extra.extra5,
  };

  double value(
    int steps, {
    required double heightCm,
    required double weightKg,
  }) => switch (this) {
    ActivityMetrics.steps => steps.toDouble(),
    ActivityMetrics.calories => StepMetricsUtils.calories(
      steps,
      heightCm,
      weightKg,
    ),
    ActivityMetrics.distance => StepMetricsUtils.distanceKm(steps, heightCm),
    ActivityMetrics.time => StepMetricsUtils.walkingTime(
      steps,
      heightCm,
    ).inMinutes.toDouble(),
  };

  String format(double value) => switch (this) {
    ActivityMetrics.calories || ActivityMetrics.distance => value.trimDecimal,
    ActivityMetrics.steps ||
    ActivityMetrics.time => NumberFormat.decimalPattern().format(value.round()),
  };

  String titleToolTip(ChartBar bar) {
    final value = bar.value;
    return switch (this) {
      ActivityMetrics.distance =>
        "${value.toStringAsFixed(1)} km ${bar.tooltip}",
      ActivityMetrics.steps => "${value.toInt()} steps ${bar.tooltip}",
      ActivityMetrics.calories =>
        "${value.toStringAsFixed(1)} kcal ${bar.tooltip}",
      ActivityMetrics.time => "${value.toInt()} min ${bar.tooltip}",
    };
  }

  String textAvgChart(double value, PeriodType period) {
    return switch (this) {
      ActivityMetrics.distance ||
      ActivityMetrics.calories => "Avg ${value.toStringAsFixed(1)}/${period.unit}",
      ActivityMetrics.steps ||
      ActivityMetrics.time => "Avg ${value.round()}/${period.unit}",
    };
  }

  AssetGenImage get icon => switch (this) {
    ActivityMetrics.steps => Assets.images.icStep,
    ActivityMetrics.calories => Assets.images.icCalory,
    ActivityMetrics.distance => Assets.images.icDistance,
    ActivityMetrics.time => Assets.images.icTime,
  };
}
