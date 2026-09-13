import 'package:flutter/material.dart';

import '../../../generated/colors.gen.dart';
import '../../../generated/text_styles.gen.dart';
import '../scale_tap_widget.dart';

class ButtonDefault extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool enabled;
  final double marginHorizontal;
  final double marginVertical;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double paddingVertical;
  final double borderRadius;

  const ButtonDefault({
    super.key,
    required this.text,
    this.onTap,
    this.enabled = true,
    this.marginHorizontal = 16,
    this.marginVertical = 16,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.paddingVertical = 16,
    this.borderRadius = 64,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTapWidget(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: marginHorizontal,
          vertical: marginVertical,
        ),
        padding: EdgeInsets.symmetric(vertical: paddingVertical),
        // Không dùng `alignment` ở đây: Container có alignment sẽ bọc con trong
        // Align, mà Align lại giãn hết chiều cao khi ràng buộc bị chặn trên
        // (đúng trường hợp Scaffold.bottomNavigationBar) khiến nút phủ kín màn
        // hình. Căn giữa chữ bằng textAlign để nút tự co theo nội dung.
        decoration: BoxDecoration(
          color: enabled
              ? (backgroundColor ?? ColorName.primary100)
              : ColorName.buttonDisabled,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: 1.5),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyles.title.bold.copyWith(
            color: textColor ?? ColorName.neutralWhite,
          ),
        ),
      ),
    );
  }
}
