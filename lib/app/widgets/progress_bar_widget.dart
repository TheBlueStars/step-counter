import 'package:flutter/material.dart';
import 'package:project/app/data/models/enums/progress_indicator_type.dart';
import 'package:project/generated/colors.gen.dart';

class ProgressBarWidget extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? spacing;
  final double? height;
  final double? borderRadius;
  final ProgressIndicatorType type;

  const ProgressBarWidget({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
    this.spacing,
    this.height,
    this.borderRadius,
    this.type = ProgressIndicatorType.separated,
  });

  Color get _activeColor => activeColor ?? ColorName.primary100;

  Color get _inactiveColor => inactiveColor ?? ColorName.neutralWhite;

  double get _radius => borderRadius ?? 8;

  double get _height => height ?? 4;

  @override
  Widget build(BuildContext context) {
    if (type.isLinear) {
      return _buildLinearBar();
    }

    return Row(
      spacing: spacing ?? 4,
      children: List.generate(totalSteps, _buildStepBar),
    );
  }

  Widget _buildLinearBar() {
    final double ratio = totalSteps <= 0
        ? 0
        : (currentStep / totalSteps).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      height: _height,
      decoration: BoxDecoration(
        color: _inactiveColor,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        widthFactor: ratio,
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          decoration: BoxDecoration(
            color: _activeColor,
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
    );
  }

  Widget _buildStepBar(int index) {
    final bool isActive = index < currentStep;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _height,
        decoration: BoxDecoration(
          color: isActive ? _activeColor : _inactiveColor,
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? _activeColor
                  : _inactiveColor.withValues(alpha: 0),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }
}
