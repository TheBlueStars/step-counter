import 'package:flutter/material.dart';
import 'package:project/app/extensions/number_extension.dart';
import 'package:project/app/widgets/default/card_default.dart';
import 'package:project/generated/assets.gen.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

import 'ring_progress_painter.dart';

class GoalProgressCard extends StatelessWidget {
  final double progress;
  final String title;
  final AssetGenImage icon;

  const GoalProgressCard({
    super.key,
    required this.progress,
    required this.icon,
    this.title = "GOAL PROGRESS",
  });

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return CardDefault(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          Row(
            children: [
              icon.image(width: 24, height: 24),
              SizedBox(width: 6),
              Expanded(
                child: TnmText.description(
                  title,
                ).medium.copyWith(maxLines: 1),
              ),
            ],
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, animated, _) => SizedBox(
                width: 52,
                height: 52,
                child: CustomPaint(
                  painter: RingProgressPainter(
                    progress: animated,
                    color: ColorName.primary100,
                    trackColor: ColorName.neutralLightGray,
                    strokeWidth: 4,
                    gradientColors: ColorName.gradientProgressPrimary.colors,
                  ),
                  child: Center(
                    child: TnmText.description(
                      "${(animated * 100).trimDecimal}%",
                    ).medium.copyWith(color: ColorName.primary100),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
