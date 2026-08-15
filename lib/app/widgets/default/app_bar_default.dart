import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarDefault extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget? leading;
  final Widget? middle;
  final Function()? leadingCallBack;
  final Color? backIconColor;
  final double? subWidgetSize;

  const AppBarDefault({
    super.key,
    this.title = "",
    this.action,
    this.leading,
    this.middle,
    this.leadingCallBack,
    this.backIconColor,
    this.subWidgetSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ).copyWith(top: 5 + MediaQuery.of(Get.context!).padding.top),
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: subWidgetSize ?? Get.width * 0.25,
            // alignment: AppStore.languageService.isRTL
            //     ? Alignment.centerRight
            //     : Alignment.centerLeft,
            child: leading ?? _buildLeadingWidget(context),
          ),
          Expanded(
            child:
                middle ??
                AlpTexts.h4(title).bold
                    .updateStyle(color: ColorName.neutralBlack)
                    .copyWith(textAlign: TextAlign.center, maxLines: 1),
          ),
          Container(
            width: subWidgetSize ?? Get.width * 0.25,
            alignment: AppStore.languageService.isRTL
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: action,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingWidget(BuildContext context) {
    return (ModalRoute.of(context)?.impliesAppBarDismissal ?? false)
        ? ScaleTapWidget(
            onTap:
                leadingCallBack ??
                () async {
                  await AppStore.onBackWithInterBack();
                },
            child: Icon(
              Icons.arrow_back_ios,
              color: backIconColor ?? ColorName.onColorText,
              size: 18.w,
            ),
          )
        : const SizedBox();
  }
}
