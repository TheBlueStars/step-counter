import 'package:project/app/utils/time_utils.dart';

extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get startOfWeek => startOfDay.subtract(Duration(days: weekday - 1));

  DateTime get endOfWeek => startOfDay.add(Duration(days: 7 - weekday));

  bool get isToday => TimeUtils.isSameDate(this, DateTime.now());

  String get dd => day.toString().padLeft(2, '0');

  String get mm => month.toString().padLeft(2, '0');

  String get yyyy_MM_dd => "$year-$mm-$dd";

  String get EEE => switch (weekday) {
    DateTime.monday => "Mon",
    DateTime.tuesday => "Tue",
    DateTime.wednesday => "Wed",
    DateTime.thursday => "Thu",
    DateTime.friday => "Fri",
    DateTime.saturday => "Sat",
    _ => "Sun",
  };

  String get MMM => switch (month) {
    1 => "Jan",
    2 => "Feb",
    3 => "Mar",
    4 => "Apr",
    5 => "May",
    6 => "Jun",
    7 => "Jul",
    8 => "Aug",
    9 => "Sep",
    10 => "Oct",
    11 => "Nov",
    _ => "Dec",
  };

  String get MMMM => switch (month) {
    1 => "January",
    2 => "February",
    3 => "March",
    4 => "April",
    5 => "May",
    6 => "June",
    7 => "July",
    8 => "August",
    9 => "September",
    10 => "October",
    11 => "November",
    _ => "December",
  };

  String get yyyy => "$year";

  String get MMMyyyy => "$MMM $yyyy";

  String get MMM_EEEdd => "$MMM, $EEE $dd";

  String get MMMMdd => "$MMMM $dd";

  String get weekLabel {
    final start = startOfWeek;
    final end = endOfWeek;
    return "${start.MMM} ${start.dd} - ${end.MMM} ${end.dd}";
  }
}
