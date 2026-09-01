import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../generated/colors.gen.dart';
import '../default/bottom_sheet_default.dart';
import '../wheel_picker_widget.dart';

class WheelOptionsSheet {
  static Future<int?> show({
    required String title,
    required List<String> labels,
    required int selectedIndex,
  }) {
    if (labels.isEmpty) {
      return Future.value(null);
    }

    final selected = ValueNotifier<int>(
      selectedIndex.clamp(0, labels.length - 1),
    );

    return BottomSheetDefault.show<int>(
      title: title,
      body: _WheelBody(labels: labels, selected: selected),
      primaryText: "Save",
      onPrimary: () => Get.back(result: selected.value),
      secondaryText: "Cancel",
    ).whenComplete(() => BottomSheetDefault.disposeLater(selected.dispose));
  }
}

class _WheelBody extends StatelessWidget {
  final List<String> labels;
  final ValueNotifier<int> selected;

  const _WheelBody({required this.labels, required this.selected});

  @override
  Widget build(BuildContext context) {
    return WheelPickerWidget<String>(
      visibleItemCount: 3,
      looping: false,
      items: labels,
      indicatorColor: ColorName.neutralLightGray,
      selectedItem: labels[selected.value],
      onChanged: (value) => selected.value = labels.indexOf(value),
    );
  }
}
