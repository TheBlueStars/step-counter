import '../../extensions/number_extension.dart';
import 'wheel_options_sheet.dart';

enum HourWheelPickerCase { pastFromNow, futureFromNow, allDay }

class HourRangePickerSheet {
  static Future<int?> show({
    required int selectedHour,
    HourWheelPickerCase pickerCase = HourWheelPickerCase.pastFromNow,
    String? title,
  }) {
    final currentHour = DateTime.now().hour;

    final (minHour, maxHour) = switch (pickerCase) {
      HourWheelPickerCase.pastFromNow => (0, currentHour),
      HourWheelPickerCase.futureFromNow => (currentHour, 23),
      HourWheelPickerCase.allDay => (0, 23),
    };

    return showRange(
      selectedHour: selectedHour,
      minHour: minHour,
      maxHour: maxHour,
      title: title,
    );
  }

  static Future<int?> showRange({
    required int selectedHour,
    int minHour = 0,
    int maxHour = 23,
    String? title,
  }) async {
    final index = await WheelOptionsSheet.show(
      title: title ?? "Time",
      labels: [for (var h = minHour; h <= maxHour; h++) h.hourRangeLabel],
      selectedIndex: selectedHour - minHour,
    );

    if (index == null) {
      return null;
    }

    return minHour + index;
  }
}
