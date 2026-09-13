import 'package:flutter/material.dart';

import '../../../generated/colors.gen.dart';
import '../../../generated/text_styles.gen.dart';
import 'button_default.dart';

class RewardBottomSection extends StatelessWidget {
  const RewardBottomSection({
    super.key,
    required this.title,
    required this.description,
    required this.showActions,
    required this.primaryText,
    this.secondaryText,
    this.onTapPrimary,
    this.onTapSecondary,
  });

  final String title;
  final String description;
  final bool showActions;
  final String primaryText;
  final String? secondaryText;
  final VoidCallback? onTapPrimary;
  final VoidCallback? onTapSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        _buildAppear(_buildText()),
        if (showActions) _buildAppear(_buildActions()),
      ],
    );
  }

  Widget _buildAppear(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 16),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _buildText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.h4.semiBold.copyWith(
              color: ColorName.neutralWhite,
            ),
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyles.title.medium.copyWith(
              color: ColorName.neutralWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ButtonDefault(
          text: primaryText,
          onTap: onTapPrimary,
          backgroundColor: ColorName.buttonBackground,
          textColor: ColorName.neutralWhite,
          paddingVertical: 10,
          marginVertical: 0,
        ),
        if (secondaryText != null)
          ButtonDefault(
            text: secondaryText!,
            onTap: onTapSecondary,
            backgroundColor: ColorName.neutralWhite,
            textColor: ColorName.buttonBackground,
            borderColor: ColorName.buttonBackground,
            paddingVertical: 10,
            marginVertical: 12,
          ),
      ],
    );
  }
}
