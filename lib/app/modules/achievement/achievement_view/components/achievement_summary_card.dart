import 'package:flutter/material.dart';
import 'package:project/app/data/models/enums/progress_indicator_type.dart';
import 'package:project/app/widgets/default/card_default.dart';
import 'package:project/app/widgets/progress_bar_widget.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

class AchievementSummaryCard extends StatelessWidget {
  final int achieved;
  final int total;

  const AchievementSummaryCard({
    super.key,
    required this.achieved,
    required this.total,
  });

  int get percent => total <= 0 ? 0 : (achieved / total * 100).round();

  @override
  Widget build(BuildContext context) {
    return CardDefault(
      borderType: CardBorderType.Normal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 4,
            children: [
              Expanded(
                child: TnmText.title(
                  "Total achievements",
                ).semiBold.copyWith(color: ColorName.neutralBlack),
              ),
              TnmText.title(
                "$achieved/$total",
              ).semiBold.copyWith(color: ColorName.primary100),
            ],
          ),
          SizedBox(height: 12),
          Row(
            spacing: 4,
            children: [
              Expanded(
                child: TnmText.description(
                  "Completion",
                ).copyWith(color: ColorName.neutralGray),
              ),
              TnmText.description(
                "$percent%",
              ).semiBold.copyWith(color: ColorName.primary100),
            ],
          ),
          SizedBox(height: 8),

          ProgressBarWidget(
            type: ProgressIndicatorType.linear,
            totalSteps: total,
            currentStep: achieved,
            inactiveColor: ColorName.borderBackground,
            height: 6,
          ),
        ],
      ),
    );
  }
}
