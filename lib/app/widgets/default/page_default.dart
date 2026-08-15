import 'package:alphalogy_get_x_wrapper/alphalogy_get_x_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/colors.gen.dart';
import '../../extensions/app_app_store_extension.dart';

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

        // await AppStore.onBackWithInterBack();
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
                      : ColorName.gradientBackgroundPrimary.linearGradient(
                          begin: .topCenter,
                          end: .bottomCenter,
                        )),
              image: !useBackgroundImage
                  ? null
                  : DecorationImage(
                      image: Assets.images.imgSplash.provider(),
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
