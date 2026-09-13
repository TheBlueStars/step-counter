import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/text_styles.gen.dart';
import '../../data/models/enums/gender.dart';
import '../option_selection_widget.dart';

class GenderSelection extends StatelessWidget {
  final Gender selectedGender;
  final ValueChanged<Gender> onGenderSelected;

  const GenderSelection({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: Gender.values.map((gender) {
        final isSelected = selectedGender == gender;
        final icon = gender.icon;

        return OptionSelectionWidget(
          isSelected: isSelected,
          onTap: () => onGenderSelected(gender),
          leadingChild: Row(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) icon.image(width: 32, height: 32),
              Text(gender.displayName, style: TextStyles.body),
            ],
          ),
          trailingChild: isSelected
              ? Assets.images.icCheck.image(width: 24, height: 24)
              : const SizedBox.shrink(),
        );
      }).toList(),
    );
  }
}
