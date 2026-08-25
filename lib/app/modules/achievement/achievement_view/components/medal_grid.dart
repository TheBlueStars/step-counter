import 'package:flutter/material.dart';
import 'package:project/app/data/models/enums/achievement.dart';
import 'package:project/app/data/models/medal_record.dart';
import 'package:project/app/widgets/default/card_default.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';
import 'package:project/app/widgets/staggered_fade_in.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

import 'medal_card.dart';

class MedalGrid extends StatefulWidget {
  final Achievement achievement;
  final List<MedalRecord> medalRecords;
  final int progress;
  final MedalRecord? currentMedal;
  final void Function(MedalRecord medal)? onTapMedal;

  const MedalGrid({
    super.key,
    required this.achievement,
    required this.medalRecords,
    required this.progress,
    this.currentMedal,
    this.onTapMedal,
  });

  @override
  State<MedalGrid> createState() => _MedalGridState();
}

class _MedalGridState extends State<MedalGrid> {
  static const int _collapsedCount = 4;
  static const int _crossAxisCount = 2;

  bool _isExpanded = false;

  List<MedalRecord> get _medals => widget.medalRecords;

  bool get _canExpand => _medals.length > _collapsedCount;

  List<MedalRecord> get _visibleMedals {
    if (_isExpanded || !_canExpand) {
      return _medals;
    }

    return _medals.take(_collapsedCount).toList();
  }

  void _onTapExpand() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TnmText.title(
          widget.achievement.displayName,
        ).medium.copyWith(color: ColorName.neutralBlack),
        CardDefault(
          borderType: CardBorderType.None,
          borderRadius: 24,
          body: Column(
            spacing: 12,
            children: [
              _buildGrid(_visibleMedals),
              if (_canExpand) _buildExpandButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<MedalRecord> medals) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 161 / 191,
      ),
      itemCount: medals.length,
      itemBuilder: (context, index) {
        final item = medals[index];
        final isCurrentMedal = widget.currentMedal == item;
        return StaggeredFadeIn(
          index: index,
          child: MedalCard(
            medalRecord: item,
            progress: widget.progress,
            onTap: widget.onTapMedal,
            isCurrentMedal: isCurrentMedal,
          ),
        );
      },
    );
  }

  Widget _buildExpandButton() {
    return ScaleTapWidget(
      onTap: _onTapExpand,
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
            color: ColorName.neutralGray,
          ),
        ),
      ),
    );
  }
}
