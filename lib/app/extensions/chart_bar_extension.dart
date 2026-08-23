import 'package:flutter/material.dart';
import 'package:project/app/data/models/chart_bar.dart';
import 'package:project/app/data/models/enums/bar_state.dart';
import 'package:project/app/data/models/enums/day_session.dart';
import 'package:project/app/data/models/enums/period_type.dart';

extension ChartBarListExtension on List<ChartBar> {
  double get peak =>
      fold<double>(0, (max, bar) => bar.value > max ? bar.value : max);

  int get peakIndex {
    var index = -1;
    var max = 0.0;
    for (var i = 0; i < length; i++) {
      if (this[i].value > max) {
        max = this[i].value;
        index = i;
      }
    }
    return index;
  }

  int get quietIndex {
    var index = -1;
    var min = double.infinity;
    for (var i = 0; i < length; i++) {
      final bar = this[i];
      if (bar.isFuture || !bar.hasData || bar.value >= min) {
        continue;
      }

      min = bar.value;
      index = i;
    }
    return index;
  }

  int get activeCount => where((bar) => bar.hasData).length;

  double get total => fold<double>(0, (sum, bar) => sum + bar.value);

  double get activeAverage {
    final values = where(
      (bar) => !bar.isFuture && bar.hasData,
    ).map((bar) => bar.value);
    if (values.isEmpty) {
      return 0;
    }

    return values.reduce((a, b) => a + b) / 24;
  }

  double averageFor(PeriodType period, DateTime date) =>
      period.isDay ? activeAverage : total / period.barCount(date);

  List<BarState> get states {
    final peak = peakIndex;
    return List.generate(length, (i) {
      final bar = this[i];
      return BarState.resolve(
        hasData: bar.hasData,
        isPeak: i == peak,
        isDone: bar.isDone,
        isFuture: bar.isFuture,
      );
    });
  }

  List<Color> shadowColors(PeriodType period) {
    final barStates = states;
    return List.generate(length, (i) {
      if (period.isDay && !this[i].isFuture) {
        return DaySession.fromHour(i).color.withValues(alpha: .5);
      }
      return barStates[i].colorShadow.withValues(alpha: .5);
    });
  }

  List<List<Color>> barGradients(PeriodType period) {
    final barStates = states;
    return List.generate(length, (i) {
      if (period.isDay && !this[i].isFuture) {
        final session = DaySession.fromHour(i);
        return [session.color, session.color];
      }

      return barStates[i].colors;
    });
  }
}
