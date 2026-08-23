import 'package:flutter/material.dart';
import 'package:project/app/widgets/default/card_default.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

class MetricValueCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? textColor;
  final Color? ellipseColor;
  final List<Color>? borderColors;
  final Widget? action;
  final Widget? iconWidgetMetric;
  final VoidCallback? onTap;

  const MetricValueCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.textColor,
    this.ellipseColor,
    this.borderColors,
    this.action,
    this.iconWidgetMetric,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ellipseColor = this.ellipseColor;
    const radius = 16.0;

    if (ellipseColor == null) {
      return ScaleTapWidget(onTap: onTap, child: _buildCard(radius));
    }

    return ScaleTapWidget(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: ColorName.neutralWhite)),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: _ellipse(ellipseColor),
            ),
            PositionedDirectional(
              bottom: 0,
              start: 0,
              child: _ellipse(ellipseColor),
            ),
            _buildCard(radius, backgroundColor: Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(double radius, {Color? backgroundColor}) {
    final borderColors = this.borderColors;
    final textColor = this.textColor;

    return CardDefault(
      width: double.infinity,
      backgroundColor: backgroundColor,
      borderRadius: radius,
      borderType: borderColors != null
          ? CardBorderType.Gradient
          : CardBorderType.Normal,
      gradientColors: borderColors,
      body: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TnmText.description(title).medium
                    .copyWith(color: textColor ?? ColorName.neutralBlack, maxLines: 1),
              ),
              ?action,
            ],
          ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    TnmText.h5(value).semiBold.copyWith(
                      color: textColor ?? ColorName.neutralBlack,
                    ),
                    TnmText.description(subtitle).copyWith(
                      color: textColor ?? ColorName.neutralGray,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              iconWidgetMetric ?? const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ellipse(Color color) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(blurRadius: 40, color: color)],
      ),
    );
  }
}
