import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/data/models/enums/achievement.dart';
import 'package:project/app/data/models/medal_record.dart';
import 'package:project/app/widgets/default/app_bar_default.dart';
import 'package:project/app/widgets/default/page_default.dart';
import 'package:project/app/widgets/filter_chips_widget.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

import '../achievement_controller/achievement_controller.dart';
import 'components/achievement_summary_card.dart';
import 'components/medal_grid.dart';
import 'components/medal_reveal_dialog.dart';

class AchievementView extends GetView<AchievementController> {
  const AchievementView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageDefault(
      appBar: AppBarDefault(
        middle: Center(
          child: TnmText.h5(
            "Achievement",
          ).bold.copyWith(color: ColorName.neutralBlack),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(),
            Obx(_buildFilters),
            Obx(() => _buildMedalGrids(context)),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return AchievementSummaryCard(
      achieved: controller.doneCount,
      total: controller.totalCount,
    );
  }

  Widget _buildFilters() {
    return FilterChipsWidget<AchievementFilter>(
      items: AchievementFilter.values,
      selectedItem: controller.filter.value,
      labelOf: (item) => item.displayName,
      onTap: controller.onTapFilter,
    );
  }

  Widget _buildMedalGrids(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: controller.medalGrids
          .map((data) => _buildMedalGrid(context, data))
          .toList(),
    ).paddingSymmetric(horizontal: 16);
  }

  Widget _buildMedalGrid(BuildContext context, MedalGridData data) {
    return MedalGrid(
      achievement: data.achievement,
      medalRecords: data.medals,
      progress: data.progress,
      currentMedal: controller.currentMedal(data.achievement),
      onTapMedal: (medal) => _onTapMedal(context, medal),
    );
  }

  void _onTapMedal(BuildContext context, MedalRecord record) {
    if (!record.isDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You haven't unlocked this medal yet!"),
        ),
      );
      return;
    }

    MedalRevealDialog.show(context, record);
  }
}
