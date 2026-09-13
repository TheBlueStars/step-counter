import 'package:flutter/material.dart';

import '../data/models/enums/progress_indicator_type.dart';
import 'progress_bar_widget.dart';
import 'progress_navigator_header.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? spacing;
  final double? height;
  final double? borderRadius;
  final double? horizontalPadding;
  final double? verticalPadding;
  final Widget? trailingIcon;
  final bool showNavigator;
  final ProgressIndicatorType type;
  final VoidCallback onTrailingIconTap;
  final VoidCallback onSkip;

  const ProgressIndicatorWidget({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.onTrailingIconTap,
    required this.onSkip,
    this.showNavigator = true,
    this.activeColor,
    this.inactiveColor,
    this.spacing,
    this.height,
    this.borderRadius,
    this.trailingIcon,
    this.horizontalPadding,
    this.verticalPadding,
    this.type = ProgressIndicatorType.separated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 16,
        vertical: verticalPadding ?? 0,
      ),
      child: Column(
        children: [
          Visibility(
            visible: showNavigator,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: ProgressNavigatorHeader(
              canGoBack: currentStep > 0,
              trailingIcon: trailingIcon,
              onBack: onTrailingIconTap,
              onSkip: onSkip,
            ),
          ),
          const SizedBox(height: 12),
          ProgressBarWidget(
            totalSteps: totalSteps,
            currentStep: currentStep,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            spacing: spacing,
            height: height,
            borderRadius: borderRadius,
            type: type,
          ),
        ],
      ),
    );
  }
}
