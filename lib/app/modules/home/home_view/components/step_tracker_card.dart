import 'package:flutter/material.dart';
import 'package:project/app/modules/home/home_view/components/gauge_progress_painter.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';
import 'package:project/generated/text_styles.gen.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../../generated/colors.gen.dart';
import '../../../../extensions/number_extension.dart';

class StepTrackerCard extends StatelessWidget {
  final int steps;
  final int stepGoal;
  final Duration elapsedTime;
  final double calories;
  final double distance;
  final bool isTracking;
  final VoidCallback? onTapPlay;
  final VoidCallback? onTapReset;
  final VoidCallback? onTapEditGoal;
  final VoidCallback? onTapEditStep;
  final VoidCallback? onTapStats;
  final VoidCallback? onTapChart;
  final VoidCallback? onTapDashBoardTime;
  final VoidCallback? onTapDashBoardCalories;
  final VoidCallback? onTapDashBoardKm;
  final VoidCallback? onGaugeAnimated;

  const StepTrackerCard({
    super.key,
    this.steps = 3331,
    this.stepGoal = 6000,
    this.elapsedTime = const Duration(hours: 3, minutes: 4),
    this.calories = 120.0,
    this.distance = 12.1,
    this.isTracking = true,
    this.onTapPlay,
    this.onTapReset,
    this.onTapEditGoal,
    this.onTapEditStep,
    this.onTapStats,
    this.onTapChart,
    this.onTapDashBoardTime,
    this.onTapDashBoardCalories,
    this.onTapDashBoardKm,
    this.onGaugeAnimated,
  });

  double get _progress {
    if (stepGoal <= 0) {
      return 0;
    }

    return (steps / stepGoal).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: ColorName.neutralWhite,
        borderRadius: BorderRadius.circular(24),
        border: .all(color: ColorName.borderBackground),
      ),
      child: Column(
        children: [
          _buildGaugeSection(),
          SizedBox(height: 16),
          _buildStatCards(),
        ],
      ),
    );
  }

  Widget _buildGaugeSection() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          Center(
            child: ScaleTapWidget(onTap: onTapChart, child: _buildGauge()),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            child: Column(
              children: [
                _buildCornerButton(
                  icon: Assets.svg.icLineEditProgress.svg(),
                  onTap: onTapEditGoal,
                ),
                SizedBox(height: 8),
                _buildCornerButton(
                  icon: Assets.svg.icLineReset.svg(),
                  onTap: onTapReset,
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Column(
              children: [
                _buildCornerButton(
                  icon: Assets.svg.icLineEdit.svg(),
                  onTap: onTapEditStep,
                ),
                SizedBox(height: 8),
                _buildCornerButton(
                  icon: Assets.svg.icLineStatical.svg(),
                  onTap: onTapStats,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _progress),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      onEnd: onGaugeAnimated,
      builder: (_, value, child) => SizedBox(
        width: 178,
        height: 178,
        child: CustomPaint(
          painter: GaugeProgressPainter(
            progress: value,
            color: ColorName.mainText,
            trackColor: ColorName.neutralLightGray,
            strokeWidth: 20,
            gradientColors: ColorName.gradientProgressPrimary.colors,
            shadowColor: ColorName.primary100.withValues(alpha: .45),
          ),
          child: child,
        ),
      ),
      child: _buildGaugeCenter(),
    );
  }

  Widget _buildGaugeCenter() {
    // final formatter = NumberFormat.decimalPattern();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 36),
        TnmText.body(
          "Step",
        ).copyWith(color: ColorName.neutralGray),
        TnmText.h4(steps.toString()).semiBold.copyWith(color: ColorName.neutralBlack),
        TnmText.body(
          "/ ${stepGoal.toString()}",
        ).copyWith(color: ColorName.neutralGray),
        SizedBox(height: 8),
        _buildPlayButton(),
      ],
    );
  }

  Widget _buildPlayButton() {
    return ScaleTapWidget(
      onTap: onTapPlay,
      child: Container(
        width: 48,
        height: 48,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorName.neutralWhite,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 8,
              color: ColorName.neutralBlack.withValues(alpha: .1),
            ),
          ],
        ),
        child: isTracking
            ? Assets.svg.icBoldPlay.svg()
            : Assets.svg.icBoldPause.svg(),
      ),
    );
  }

  Widget _buildCornerButton({required Widget icon, VoidCallback? onTap}) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorName.secondary20,
        ),
        child: icon,
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: _formatDuration(elapsedTime),
            label: "time",
            onTap: onTapDashBoardTime,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            value: calories.trimDecimal,
              label: "kcal",
            onTap: onTapDashBoardCalories,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            value: distance.trimDecimal,
            label: "km",
            onTap: onTapDashBoardKm,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: ColorName.neutralWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorName.borderBackground),
        ),
        child: Column(
          children: [
            TnmText.title(value).semiBold.copyWith(color: ColorName.neutralBlack),
            SizedBox(height: 2),
            TnmText.description(
              label,
            ).copyWith(color: ColorName.neutralGray),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) =>
      "${duration.inHours}h ${duration.inMinutes % 60}m";
}
