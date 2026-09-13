import 'package:flutter/material.dart';

import '../../generated/colors.gen.dart';
import 'default/card_default.dart';

class OptionSelectionWidget extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget leadingChild;
  final Widget trailingChild;

  const OptionSelectionWidget({
    super.key,
    required this.isSelected,
    required this.leadingChild,
    required this.trailingChild,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardDefault(
      borderColor: isSelected ? ColorName.primary100 : ColorName.inputBorder,
      backgroundColor: isSelected
          ? ColorName.primary20
          : ColorName.neutralWhite,
      borderRadius: 64,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      hasShadow: isSelected,
      onTap: onTap,
      body: SizedBox(
        height: 52,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Expanded(child: leadingChild), trailingChild],
        ),
      ),
    );
  }
}
