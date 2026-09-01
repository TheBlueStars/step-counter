import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/extensions/number_extension.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';
import 'package:project/app/widgets/wheel/date_range_picker_sheet.dart';
import 'package:project/app/widgets/wheel/hour_range_picker_sheet.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

enum EditStepAction { pickDate, pickTime, save }

class EditStepDraft {
  DateTime day;
  int hour;

  EditStepDraft({required this.day, required this.hour});

  bool get isToday => day.isToday;

  DateTime get hourStart => DateTime(day.year, day.month, day.day, hour);

  String get dateLabel => isToday ? "Today" : "${day.dd}/${day.mm}/${day.year}";

  String get timeLabel => hour.hourRangeLabel;

  Future<void> pickDate() async {
    final picked = await DateRangePickerSheet.show(
      initial: day,
      pickerCase: DateWheelPickerCase.pastTwoYears,
    );

    if (picked == null) {
      return;
    }

    day = picked;

    final now = DateTime.now();
    if (isToday && hour > now.hour) {
      hour = now.hour;
    }
  }

  Future<void> pickTime() async {
    final picked = isToday
        ? await HourRangePickerSheet.show(
            selectedHour: hour,
            pickerCase: HourWheelPickerCase.pastFromNow,
          )
        : await HourRangePickerSheet.showRange(selectedHour: hour);

    if (picked == null) {
      return;
    }

    hour = picked;
  }
}

class EditStepSheetBody extends StatelessWidget {
  final EditStepDraft draft;
  final TextEditingController controller;

  const EditStepSheetBody({
    super.key,
    required this.draft,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Date"),
        _buildPickerRow(
          value: draft.dateLabel,
          onTap: () => Get.back(result: EditStepAction.pickDate),
        ),
        SizedBox(height: 12),
        _buildLabel("Time"),
        _buildPickerRow(
          value: draft.timeLabel,
          onTap: () => Get.back(result: EditStepAction.pickTime),
        ),
        SizedBox(height: 12),
        _buildLabel("Steps"),
        _buildStepsField(),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsetsDirectional.only(bottom: 8),
    child: TnmText.title(text).copyWith(color: ColorName.disabledText),
  );

  Widget _buildPickerRow({required String value, required VoidCallback onTap}) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ColorName.neutralWhite,
          borderRadius: BorderRadius.circular(64),
          border: Border.all(color: ColorName.buttonBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: TnmText.body(
                value,
              ).copyWith(color: ColorName.neutralBlack),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: ColorName.neutralGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsField() {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(64),
          borderSide: BorderSide(color: ColorName.buttonBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(64),
          borderSide: BorderSide(color: ColorName.primary100),
        ),
      ),
    );
  }
}
