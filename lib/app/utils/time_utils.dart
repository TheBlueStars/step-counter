  class TimeUtils {
  static DateTime absoluteNow = DateTime.now();

  static DateTime now = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  static final List<int> hourList = [for (var h = 0; h <= 23; h++) h];

  static final List<int> minuteList = [for (var m = 0; m <= 59; m++) m];

  static List<DateTime> weekDays = [
    for (var i = 0; i < 7; i++)
      now.subtract(Duration(days: now.weekday - 1 - i)),
  ];

  static List<DateTime> getCurrentWeek() {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    List<DateTime> weekList = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      weekList.add(day);
    }

    return weekList;
  }

  static DateTime atMinutesInDay(DateTime day, int minutesInDay) => DateTime(
    day.year,
    day.month,
    day.day,
    minutesInDay ~/ 60,
    minutesInDay % 60,
  );

  static bool get isToday {
    final today = DateTime.now();
    return now.year == today.year &&
        now.month == today.month &&
        now.day == today.day;
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameWeek(DateTime a, DateTime b) {
    final startOfWeek = a.subtract(Duration(days: a.weekday - 1));
    final endOfWeek = a.add(Duration(days: 7 - a.weekday));

    return b.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        b.isBefore(endOfWeek.add(const Duration(seconds: 1)));
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static bool isSameYear(DateTime a, DateTime b) {
    return a.year == b.year;
  }

  static String hourMin(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
