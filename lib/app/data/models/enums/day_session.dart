import 'dart:ui';

import '../../../../generated/colors.gen.dart';

enum DaySession {
  morning,
  afternoon,
  evening,
  night;

  static DaySession fromHour(int hour) {
    if (hour >= 5 && hour <= 11) {
      return DaySession.morning;
    }

    if (hour >= 12 && hour <= 16) {
      return DaySession.afternoon;
    }

    if (hour >= 17 && hour <= 20) {
      return DaySession.evening;
    }

    return DaySession.night;
  }

  String get label => switch (this) {
    DaySession.morning => "Morning",
    DaySession.afternoon => "Afternoon",
    DaySession.evening => "Evening",
    DaySession.night => "Night",
  };

  Color get color => switch (this) {
    DaySession.morning => ColorName.errorStatus,
    DaySession.afternoon => ColorName.primary100,
    DaySession.evening => ColorName.infoStatus,
    DaySession.night => ColorName.successStatus,
  };
}
