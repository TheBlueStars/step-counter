import 'package:flutter/material.dart';

import '../../generated/text_styles.gen.dart';
import 'scale_tap_widget.dart';

class ProgressNavigatorHeader extends StatelessWidget {
  final bool canGoBack;
  final Widget? trailingIcon;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const ProgressNavigatorHeader({
    super.key,
    required this.canGoBack,
    required this.onBack,
    required this.onSkip,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IgnorePointer(
          ignoring: !canGoBack,
          child: AnimatedOpacity(
            opacity: canGoBack ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: _buildItem(
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
              onTap: onBack,
            ),
          ),
        ),
        _buildItem(
          child:
              trailingIcon ??
              Text(
                "Skip",
                style: TextStyles.body.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
          onTap: onSkip,
        ),
      ],
    );
  }

  Widget _buildItem({required Widget child, required VoidCallback onTap}) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: child,
      ),
    );
  }
}
