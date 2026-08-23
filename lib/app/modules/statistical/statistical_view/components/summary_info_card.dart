import 'package:flutter/material.dart';
import 'package:project/app/widgets/default/card_default.dart';
import 'package:project/generated/assets.gen.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

class SummaryInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final AssetGenImage icon;

  const SummaryInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return CardDefault(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 4,
            children: [
              icon.image(width: 24, height: 24),
              Expanded(
                child: TnmText.description(
                  title,
                ).medium.copyWith(maxLines: 1).copyWith(color: ColorName.neutralBlack),
              ),
            ],
          ),
          TnmText.h5(value).semiBold.copyWith(color: ColorName.neutralBlack),

          if (subtitle.isNotEmpty)
            TnmText.description(
              value == '0' ? "No records yet" : subtitle,
            ).copyWith(color: ColorName.neutralGray, maxLines: 1),
        ],
      ),
    );
  }
}
