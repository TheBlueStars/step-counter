import 'package:flutter/material.dart';

import '../../../generated/colors.gen.dart';
import '../../../generated/text_styles.gen.dart';
import '../wheel_picker_widget.dart';

/// Bánh xe chọn số nguyên + phần thập phân cho chiều cao (cm) và cân nặng (kg).
class MeasurementPicker extends StatefulWidget {
  const MeasurementPicker._({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.unitLabel,
    this.showDecimalWheel = true,
    this.onChanged,
  });

  final double initialValue;
  final double minValue;
  final double maxValue;
  final String unitLabel;
  final bool showDecimalWheel;
  final ValueChanged<double>? onChanged;

  static MeasurementPicker height({
    Key? key,
    double initialCm = 170,
    ValueChanged<double>? onChanged,
  }) => MeasurementPicker._(
    key: key,
    initialValue: initialCm,
    minValue: 30,
    maxValue: 250,
    unitLabel: "CM",
    showDecimalWheel: false,
    onChanged: onChanged,
  );

  static MeasurementPicker weight({
    Key? key,
    double initialKg = 60,
    ValueChanged<double>? onChanged,
  }) => MeasurementPicker._(
    key: key,
    initialValue: initialKg,
    minValue: 1,
    maxValue: 199,
    unitLabel: "KG",
    onChanged: onChanged,
  );

  @override
  State<MeasurementPicker> createState() => _MeasurementPickerState();
}

class _MeasurementPickerState extends State<MeasurementPicker> {
  late double _value = widget.initialValue;

  List<int> get _wholeValues {
    final min = widget.minValue.ceil();
    final max = widget.maxValue.floor();

    return List.generate(max - min + 1, (index) => min + index);
  }

  List<int> get _decimalValues => List.generate(10, (index) => index);

  int get _tenths => (_value * 10).round();

  int get _wholeValue => _tenths ~/ 10;

  int get _decimalValue => _tenths % 10;

  void _onWholeChanged(int value) => _setValue(value + _decimalValue / 10);

  void _onDecimalChanged(int digit) => _setValue(_wholeValue + digit / 10);

  void _setValue(double value) {
    if ((value * 10).round() == _tenths) {
      return;
    }

    setState(() => _value = value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [_buildUnitLabel(), _buildValuePicker()],
    );
  }

  Widget _buildUnitLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: ColorName.primary20,
        borderRadius: BorderRadius.circular(64),
      ),
      child: Text(
        widget.unitLabel,
        style: TextStyles.title.semiBold.copyWith(color: ColorName.primary100),
      ),
    );
  }

  Widget _buildValuePicker() {
    final wholeWheel = WheelPickerWidget<int>(
      items: _wholeValues,
      selectedItem: _wholeValue,
      onChanged: _onWholeChanged,
    );

    if (!widget.showDecimalWheel) {
      return wholeWheel;
    }

    return Row(
      spacing: 16,
      children: [
        Expanded(child: wholeWheel),
        Expanded(
          child: WheelPickerWidget<int>(
            items: _decimalValues,
            selectedItem: _decimalValue,
            onChanged: _onDecimalChanged,
          ),
        ),
      ],
    );
  }
}
