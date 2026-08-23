import 'package:flutter/material.dart';
import 'package:project/app/data/models/summary_card_data.dart';

import 'goal_progress_card.dart';
import 'summary_info_card.dart';

class SummaryCardsGrid extends StatelessWidget {
  final List<SummaryCardData> cards;
  const SummaryCardsGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      final pair = cards.sublist(i, (i + 2).clamp(0, cards.length));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            for (final card in pair) Expanded(child: _buildCard(card)),
            if (pair.length == 1) const Spacer(),
          ],
        ),
      );
    }

    return Column(spacing: 12, children: rows);
  }

  Widget _buildCard(SummaryCardData card) {
    if (card.isGoal) {
      return GoalProgressCard(
        title: card.title,
        progress: card.progress ?? 0,
        icon: card.icon,
      );
    }

    return SummaryInfoCard(
      title: card.title,
      value: card.value,
      subtitle: card.subtitle,
      icon: card.icon,
    );
  }
}
