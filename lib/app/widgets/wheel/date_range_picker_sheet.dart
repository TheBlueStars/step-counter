import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../generated/colors.gen.dart';
import '../default/bottom_sheet_default.dart';
import '../wheel_picker_widget.dart';

enum DateWheelPickerCase { pastTwoYears, futureOnly }

class DateRangePickerSheet {
  static const int _rangeYears = 2;

  static Future<DateTime?> show({
    required DateTime initial,
    DateWheelPickerCase pickerCase = DateWheelPickerCase.pastTwoYears,
    String? title,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final (minDate, maxDate) = switch (pickerCase) {
      DateWheelPickerCase.pastTwoYears => (
        DateTime(today.year - _rangeYears, 1, 1),
        today,
      ),
      DateWheelPickerCase.futureOnly => (
        today,
        DateTime(today.year + _rangeYears, today.month, today.day),
      ),
    };

    return showRange(
      initial: initial,
      minDate: minDate,
      maxDate: maxDate,
      title: title,
    );
  }

  static Future<DateTime?> showRange({
    required DateTime initial,
    required DateTime minDate,
    required DateTime maxDate,
    String? title,
  }) {
    final draft = _DateDraft(
      year: initial.year,
      month: initial.month,
      day: initial.day,
    );

    return BottomSheetDefault.show<DateTime>(
      title: title ?? "Date",
      body: _DateWheelsBody(draft: draft, minDate: minDate, maxDate: maxDate),
      primaryText: "Save",
      onPrimary: () => Get.back(result: draft.clamped(minDate, maxDate)),
      secondaryText: "Cancel",
    );
  }
}

class _DateDraft {
  int year;
  int month;
  int day;

  _DateDraft({required this.year, required this.month, required this.day});

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  DateTime clamped(DateTime min, DateTime max) {
    var picked = DateTime(year, month, day);
    final minDate = DateTime(min.year, min.month, min.day);
    final maxDate = DateTime(max.year, max.month, max.day);

    if (picked.isBefore(minDate)) {
      picked = minDate;
    }

    if (picked.isAfter(maxDate)) {
      picked = maxDate;
    }

    return picked;
  }
}

class _DateWheelsBody extends StatefulWidget {
  final _DateDraft draft;
  final DateTime minDate;
  final DateTime maxDate;

  const _DateWheelsBody({
    required this.draft,
    required this.minDate,
    required this.maxDate,
  });

  @override
  State<_DateWheelsBody> createState() => _DateWheelsBodyState();
}

class _DateWheelsBodyState extends State<_DateWheelsBody> {
  static const double _columnWidth = 80;

  _DateDraft get draft => widget.draft;

  DateTime get _min => widget.minDate;

  DateTime get _max => widget.maxDate;

  (int, int) get _monthRange => (
    draft.year == _min.year ? _min.month : DateTime.january,
    draft.year == _max.year ? _max.month : DateTime.december,
  );

  (int, int) get _dayRange {
    final atMin = draft.year == _min.year && draft.month == _min.month;
    final atMax = draft.year == _max.year && draft.month == _max.month;
    return (atMin ? _min.day : 1, atMax ? _max.day : draft.daysInMonth);
  }

  List<String> _labels(int from, int to) => [
    for (var value = from; value <= to; value++)
      value.toString().padLeft(2, '0'),
  ];

  List<String> get _years => _labels(_min.year, _max.year);

  List<String> get _months => _labels(_monthRange.$1, _monthRange.$2);

  List<String> get _days => _labels(_dayRange.$1, _dayRange.$2);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildWheel(
          items: _years,
          selected: draft.year.toString(),
          onChanged: (value) => setState(() {
            draft.year = int.parse(value);
            _clampToRange();
          }),
        ),
        _buildWheel(
          items: _months,
          selected: draft.month.toString().padLeft(2, '0'),
          onChanged: (value) => setState(() {
            draft.month = int.parse(value);
            _clampToRange();
          }),
        ),
        _buildWheel(
          items: _days,
          selected: draft.day.toString().padLeft(2, '0'),
          onChanged: (value) => setState(() => draft.day = int.parse(value)),
        ),
      ],
    );
  }

  Widget _buildWheel({
    required List<String> items,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return WheelPickerWidget<String>(
      width: _columnWidth,
      widthItem: _columnWidth,
      visibleItemCount: 3,
      looping: false,
      indicatorColor: ColorName.neutralLightGray,
      items: items,
      selectedItem: selected,
      onChanged: onChanged,
    );
  }

  void _clampToRange() {
    final (minMonth, maxMonth) = _monthRange;
    draft.month = draft.month.clamp(minMonth, maxMonth);

    final (minDay, maxDay) = _dayRange;
    draft.day = draft.day.clamp(minDay, maxDay);
  }
}
