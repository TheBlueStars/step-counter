import 'package:get/get.dart';
import 'package:project/app/data/models/chart_bar.dart';
import 'package:project/app/data/models/enums/activity_metrics.dart';
import 'package:project/app/data/models/enums/period_type.dart';
import 'package:project/app/data/models/summary_card_data.dart';
import 'package:project/app/data/models/summary_statistical.dart';
import 'package:project/app/extensions/chart_bar_extension.dart';
import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/services/step_record_service.dart';
import 'package:project/generated/assets.gen.dart';

class StatisticalController extends GetxController {
  final StepRecordService _service = StepRecordService.to;

  final Rx<ActivityMetrics> _selectedMetric = Rx(ActivityMetrics.steps);
  final Rx<PeriodType> _period = Rx(PeriodType.day);
  final Rx<DateTime> _selectedDate = Rx(DateTime.now().startOfDay);

  ActivityMetrics get selectedMetric => _selectedMetric.value;

  PeriodType get period => _period.value;

  String get dateLabel => period.dateLabel(_selectedDate.value);

  bool get isAtCurrent => period.isCurrent(_selectedDate.value);

  void selectMetric(ActivityMetrics metric) => _selectedMetric.value = metric;

  void changePeriod(PeriodType period) {
    _period.value = period;
    resetToCurrent();
  }

  void previousPeriod() =>
      _selectedDate.value = period.shift(_selectedDate.value, -1);

  void nextPeriod() {
    if (isAtCurrent) {
      return;
    }

    _selectedDate.value = period.shift(_selectedDate.value, 1);
  }

  void resetToCurrent() => _selectedDate.value = DateTime.now().startOfDay;

  double get _heightCm => _service.heightCm.value;

  double get _weightKg => _service.weightKg.value;

  List<int> get _barGoals {
    final date = _selectedDate.value;

    return switch (period) {
      PeriodType.day => List.filled(24, _service.goalOfDay(date)),
      PeriodType.week => List.generate(
        7,
        (i) => _service.goalOfDay(date.startOfWeek.add(Duration(days: i))),
      ),
      PeriodType.month => List.generate(
        DateTime(date.year, date.month + 1, 0).day,
        (i) => _service.goalOfDay(DateTime(date.year, date.month, i + 1)),
      ),
      PeriodType.year => List.generate(12, (month) {
        final days = DateTime(date.year, month + 2, 0).day;
        var total = 0;
        for (var day = 1; day <= days; day++) {
          total += _service.goalOfDay(DateTime(date.year, month + 1, day));
        }

        return total;
      }),
    };
  }

  int get _axisGoal => period.isDay
      ? _goalTotal
      : _barGoals.fold<int>(0, (max, goal) => goal > max ? goal : max);

  int get _longestStreak {
    final (from, to) = period.range(_selectedDate.value);
    return _service.longestStreak(from: from, to: to);
  }

  List<int> get _rawSteps {
    _service.dataVersion.value;

    final date = _selectedDate.value;
    return switch (period) {
      PeriodType.day => _service.hourlyStepsForDay(date),
      PeriodType.week => _service.dailyStepsInRange(
        date.startOfWeek,
        date.endOfWeek,
      ),
      PeriodType.month => _service.dailyStepsInRange(
        DateTime(date.year, date.month),
        DateTime(date.year, date.month + 1, 0),
      ),
      PeriodType.year => _service.monthlyStepsForYear(date.year),
    };
  }

  List<int> get _barSteps {
    final steps = _rawSteps;
    final currentIndex = isAtCurrent
        ? period.currentIndexAt(DateTime.now())
        : null;

    return List.generate(steps.length, (i) {
      final isFuture = currentIndex != null && i > currentIndex;
      return isFuture ? 0 : steps[i];
    });
  }

  int get _goalTotal => period.isDay
      ? _service.goalOfDay(_selectedDate.value)
      : _barGoals.fold<int>(0, (sum, goal) => sum + goal);

  List<ChartBar> get chartBars {
    final date = _selectedDate.value;
    final isSteps = selectedMetric == ActivityMetrics.steps;
    final goals = _barGoals;
    final steps = _barSteps;
    final currentIndex = isAtCurrent
        ? period.currentIndexAt(DateTime.now())
        : null;

    return List.generate(steps.length, (i) {
      final isFuture = currentIndex != null && i > currentIndex;
      final rawSteps = steps[i];
      return ChartBar(
        value: _metricValue(rawSteps),
        label: period.barLabel(date, i),
        tooltip: period.barTooltip(date, i),
        isCurrent: currentIndex == i,
        isDone: isSteps && goals[i] > 0 && rawSteps >= goals[i],
        isFuture: isFuture,
      );
    });
  }

  double get chartAverage => chartBars.averageFor(period, _selectedDate.value);

  int get totalStep {
    final goal = _metricValue(_axisGoal);
    final peak = chartBars.peak;
    final max = peak > goal ? peak : goal;
    return max <= 0 ? 1 : max.ceil();
  }

  double _metricValue(int steps) =>
      selectedMetric.value(steps, heightCm: _heightCm, weightKg: _weightKg);

  int get _totalSteps => _barSteps.fold<int>(0, (sum, steps) => sum + steps);

  String get totalValue => selectedMetric.format(_metricValue(_totalSteps));

  String totalValueOf(ActivityMetrics metric) => metric.format(
    metric.value(_totalSteps, heightCm: _heightCm, weightKg: _weightKg),
  );

  String get avgValue => selectedMetric.format(chartAverage);

  List<SummaryCardData> get summaryCards =>
      _summaryStatistical.cards(selectedMetric, period);

  SummaryStatistical get _summaryStatistical {
    final date = _selectedDate.value;
    final bars = chartBars;
    final peakIndex = bars.peakIndex;
    final quietIndex = bars.quietIndex;

    return SummaryStatistical(
      peakTime: SummaryCardData.stat(
        title: "PEAK TIME",
        value: _valueAt(bars, peakIndex),
        subtitle: period.dayLabelAt(date, peakIndex),
        icon: Assets.images.icPeakTime,
      ),
      peakDay: SummaryCardData.stat(
        title: "PEAK DAY",
        value: _valueAt(bars, peakIndex),
        subtitle: period.dayLabelAt(date, peakIndex),
        icon: Assets.images.icPeakDay,
      ),
      peakMonth: SummaryCardData.stat(
        title: "PEAK MONTH",
        value: _valueAt(bars, peakIndex),
        subtitle: period.monthLabelAt(date, peakIndex),
        icon: Assets.images.icPeakDay,
      ),
      quietDay: SummaryCardData.stat(
        title: "QUIET DAY",
        value: _valueAt(bars, quietIndex),
        subtitle: period.dayLabelAt(date, quietIndex),
        icon: Assets.images.icQuietDay,
      ),
      quietMonth: SummaryCardData.stat(
        title: "QUIET MONTH",
        value: _valueAt(bars, quietIndex),
        subtitle: period.monthLabelAt(date, quietIndex),
        icon: Assets.images.icQuietDay,
      ),
      activeHours: SummaryCardData.stat(
        title: "ACTIVE HOURS",
        value: bars.activeCount.toString(),
        subtitle: "hours active",
        icon: Assets.images.icActiveHour,
      ),
      longestStreak: SummaryCardData.stat(
        title: "LONGEST STREAK",
        value: _longestStreak.toString(),
        subtitle: period.currentLabel,
        icon: Assets.images.icStreak,
      ),
      goalProgress: _goalProgress,
      goalIcon: Assets.images.icGoalProgress,
    );
  }

  double get _goalProgress {
    if (_goalTotal <= 0) {
      return 0;
    }

    return (_totalSteps / _goalTotal).clamp(0.0, 1.0);
  }

  String _valueAt(List<ChartBar> bars, int index) =>
      index < 0 || index >= bars.length
      ? "0"
      : selectedMetric.format(bars[index].value);
}
