import 'package:flutter/material.dart';
import 'package:project/app/data/models/enums/progress_indicator_type.dart';
import 'package:project/app/data/models/medal_record.dart';
import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/widgets/default/card_default.dart';
import 'package:project/app/widgets/progress_bar_widget.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

class MedalCard extends StatelessWidget {
  final MedalRecord medalRecord;
  final int progress;
  final bool isCurrentMedal;
  final void Function(MedalRecord medal)? onTap;

  const MedalCard({
    super.key,
    required this.medalRecord,
    required this.progress,
    required this.isCurrentMedal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardDefault(
      onTap: onTap == null ? null : () => onTap!(medalRecord),
      padding: EdgeInsets.all(12),

      body: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(child: _buildImage()),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TnmText.body(medalRecord.medal.title).medium
            .copyWith(color: ColorName.neutralBlack, maxLines: 1),
        SizedBox(height: isCurrentMedal || medalRecord.isDone ? 4 : 12),
        medalRecord.isDone ? _buildDoneAt() : _buildProgress(),
      ],
    );
  }

  Widget _buildImage() {
    final Widget image = medalRecord.medal.image.image(width: 135, height: 100);
    if (medalRecord.isDone) {
      return image;
    }

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.3, 0.6, 0.1, 0, -15,
        0.3, 0.6, 0.1, 0, -15,
        0.3, 0.6, 0.1, 0, -15,
        0, 0, 0, 1, 0,
      ]),
      child: image,
    );
  }

  Widget _buildDoneAt() {
    final doneAt = medalRecord.doneAt;
    if (doneAt == null) {
      return const SizedBox.shrink();
    }

    return TnmText.description(
      doneAt.yyyy_MM_dd,
    ).copyWith(color: ColorName.neutralGray);
  }

  Widget _buildProgress() {
    if (!isCurrentMedal) {
      return const SizedBox();
    }

    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 4,
          children: [
            Expanded(
              child: TnmText.description(
                "$progress/${medalRecord.medal.goal}",
              ).copyWith(color: ColorName.neutralGray),
            ),
            TnmText.description(
              "${medalRecord.percentOf(progress)}%",
            ).semiBold.copyWith(color: ColorName.primary100),
          ],
        ),
        ProgressBarWidget(
          type: ProgressIndicatorType.linear,
          totalSteps: medalRecord.medal.goal,
          currentStep: progress,
          inactiveColor: ColorName.borderBackground,
          height: 6,
        ),
      ],
    );
  }
}
