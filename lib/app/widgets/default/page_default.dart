import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../generated/colors.gen.dart';

class PageDefault extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool useBackgroundImage;
  final bool isShowInterBack;
  final Gradient? gradient;
  final bool Function()? canBack;

  const PageDefault({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.useBackgroundImage = false,
    this.isShowInterBack = true,
    this.gradient,
    this.canBack,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (canBack?.call() == false) return;

        if (!isShowInterBack) return Get.back();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          backgroundColor: backgroundColor ?? ColorName.background,
          bottomNavigationBar: bottomNavigationBar,
          bottomSheet: bottomSheet,
          body: Container(
            width: Get.width,
            height: Get.height,
            decoration: BoxDecoration(
              gradient:
                  gradient ??
                  (backgroundColor != null
                      ? null
                      : LinearGradient(
                          colors: ColorName.gradientBackgroundPrimary.colors,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )),
              image: !useBackgroundImage
                  ? null
                  : const DecorationImage(
                      image: AssetImage(
                        'assets/images/img_background_splash.png',
                      ),
                      fit: BoxFit.fill,
                    ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                appBar ?? const SizedBox(),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
