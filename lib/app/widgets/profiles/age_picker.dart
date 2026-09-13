import 'package:flutter/material.dart';

import '../wheel_picker_widget.dart';

class AgePicker extends StatelessWidget {
  final int selectedAge;
  final ValueChanged<int>? onChanged;

  const AgePicker({super.key, this.selectedAge = 25, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ages = List.generate(120, (index) => index + 1);

    return WheelPickerWidget<int>(
      items: ages,
      selectedItem: selectedAge,
      onChanged: onChanged ?? (_) {},
    );
  }
}
