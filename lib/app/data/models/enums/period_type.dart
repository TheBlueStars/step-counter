import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/extensions/number_extension.dart';
import 'package:project/app/utils/time_utils.dart';

enum PeriodType {
  day,
  week,
  month,
  year;

  String get label => switch (this) {
    PeriodType.day => "Day",
    PeriodType.week => "Week",
    PeriodType.month => "Month",
    PeriodType.year => "Year",
  };

  String get unit => switch (this) {
    PeriodType.day => "hr",
    PeriodType.year => "month",
    _ => "day",
  };

  String get goalTitle => switch (this) {
    PeriodType.day => "GOAL PROGRESS",
    PeriodType.week => "WEEKLY GOAL",
    PeriodType.month => "MONTHLY GOAL",
    PeriodType.year => "YEARLY GOAL",
  };

  String get currentLabel => switch (this) {
    PeriodType.day => "Current best streak  ",
    PeriodType.week => "This week",
    PeriodType.month => "This month",
    PeriodType.year => "This year",
  };

  bool get isDay => this == PeriodType.day;
  bool get isWeek => this == PeriodType.week;
  bool get isMonth => this == PeriodType.month;
  bool get isYear => this == PeriodType.year;

  bool showLabelAt(int index, int count) => switch (this) {
    PeriodType.day => index % 3 == 0,
    PeriodType.week => true,
    PeriodType.month =>
      index == 0 || index == 9 || index == 19 || index == count - 1,
    PeriodType.year => index % 2 == 0,
  };

  (DateTime, DateTime) range(DateTime date) => switch (this) {
    PeriodType.day => (date, date),
    PeriodType.week => (date.startOfWeek, date.endOfWeek),
    PeriodType.month => (
      DateTime(date.year, date.month),
      DateTime(date.year, date.month + 1, 0),
    ),
    PeriodType.year => (DateTime(date.year), DateTime(date.year, 12, 31)),
  };

  String dateLabel(DateTime date) => switch (this) {
    PeriodType.day => date.MMM_EEEdd,
    PeriodType.week => date.weekLabel,
    PeriodType.month => date.MMMyyyy,
    PeriodType.year => date.yyyy,
  };

  bool isCurrent(DateTime date) {
    final now = DateTime.now();
    return switch (this) {
      PeriodType.day => TimeUtils.isSameDate(date, now),
      PeriodType.week => TimeUtils.isSameWeek(date, now),
      PeriodType.month => TimeUtils.isSameMonth(date, now),
      PeriodType.year => TimeUtils.isSameYear(date, now),
    };
  }

  DateTime shift(DateTime date, int delta) => switch (this) {
    PeriodType.day => date.add(Duration(days: delta)),
    PeriodType.week => date.add(Duration(days: 7 * delta)),
    PeriodType.month => DateTime(date.year, date.month + delta, 1),
    PeriodType.year => DateTime(date.year + delta, date.month, 1),
  };

  double get barWidth => switch (this) {
    PeriodType.day => 8,
    PeriodType.week => 22,
    PeriodType.month => 6,
    PeriodType.year => 16,
  };

  int barCount(DateTime date) => switch (this) {
    PeriodType.day => 24,
    PeriodType.week => 7,
    PeriodType.month => DateTime(date.year, date.month + 1, 0).day,
    PeriodType.year => 12,
  };

  int currentIndexAt(DateTime now) => switch (this) {
    PeriodType.day => now.hour,
    PeriodType.week => now.weekday - 1,
    PeriodType.month => now.day - 1,
    PeriodType.year => now.month - 1,
  };

  String barLabel(DateTime date, int index) => switch (this) {
    PeriodType.day => "${index == 0 ? 24 : index}h",
    PeriodType.week => date.startOfWeek.add(Duration(days: index)).EEE,
    PeriodType.month => "${index + 1}",
    PeriodType.year => DateTime(date.year, index + 1, 1).MMM,
  };

  String barTooltip(DateTime date, int index) => switch (this) {
    PeriodType.day => index.hourRangeLabel,
    PeriodType.week => date.startOfWeek.add(Duration(days: index)).MMM_EEEdd,
    PeriodType.month => DateTime(date.year, date.month, index + 1).MMMMdd,
    PeriodType.year => DateTime(date.year, index + 1, 1).MMMM,
  };

  String dayLabelAt(DateTime date, int index) {
    if (index < 0) {
      return "No records yet";
    }

    return switch (this) {
      PeriodType.day => index.hourRangeLabel,
      PeriodType.week => date.startOfWeek.add(Duration(days: index)).MMM_EEEdd,
      PeriodType.month => DateTime(date.year, date.month, index + 1).MMMMdd,
      PeriodType.year => "",
    };
  }

  String monthLabelAt(DateTime date, int index) =>
      index < 0 ? "" : DateTime(date.year, index + 1).MMMM;
}
