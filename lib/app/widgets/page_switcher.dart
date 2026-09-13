import 'package:flutter/material.dart';

class PageSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double? verticalPadding;
  final double? horizontalPadding;

  const PageSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.verticalPadding,
    this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        key: child.key,
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding ?? 0,
          horizontal: horizontalPadding ?? 16,
        ),
        child: child,
      ),
    );
  }
}
