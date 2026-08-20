

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../../generated/colors.gen.dart';
import '../../../generated/text_styles.gen.dart';
import '../../widgets/scale_tap_widget.dart';

enum CardBorderType {
  None,
  Normal,
  Gradient;

  bool get isNone => this == .None;

  bool get isNormal => this == .Normal;

  bool get isGradient => this == .Gradient;
}

class CardDefault extends StatelessWidget {
  final Widget body;
  final String? title;
  final Widget? action;
  final CardBorderType borderType;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool hasShadow;
  final List<BoxShadow>? boxShadow;
  final Function()? onTap;
  final double? width;
  final double? height;
  final CrossAxisAlignment crossAxisAlignment;

  const CardDefault({
    super.key,
    required this.body,
    this.title,
    this.action,
    this.borderType = .Normal,
    this.gradientColors,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.hasShadow = false,
    this.boxShadow,
    this.onTap,
    this.width,
    this.height,
    this.margin,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsetsDirectional.all(16),
      margin: margin ?? EdgeInsetsDirectional.zero,
      decoration: BoxDecoration(
        color: backgroundColor ?? ColorName.neutralWhite,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: _buildBorder(),
        boxShadow: _buildShadow(),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (title != null || action != null) ...[_buildHeader(), SizedBox(height: 12)],
          body,
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return ScaleTapWidget(onTap: onTap, child: card);
  }

  BoxBorder? _buildBorder() {
    return switch (borderType) {
      .None => null,
      .Normal => Border.all(color: borderColor ?? ColorName.inputBorder),
      .Gradient => GradientBoxBorder(
        gradient: LinearGradient(
          colors: gradientColors ?? ColorName.gradientBorderRed.colors,
          transform: const GradientRotation(-math.pi / 4.5),
        ),
      ),
    };
  }

  List<BoxShadow>? _buildShadow() {
    if (!hasShadow) {
      return null;
    }

    return boxShadow ??
        [
          BoxShadow(
            color: ColorName.primary100,
            offset: const Offset(0, 0),
            blurRadius: 4,
          ),
        ];
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: title == null
              ? const SizedBox()
              : TnmText.body(title!).copyWith(color: ColorName.neutralGray),
        ),
        ?action,
      ],
    );
  }
}
