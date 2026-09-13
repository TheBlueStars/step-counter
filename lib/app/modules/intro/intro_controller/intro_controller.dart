import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../generated/assets.gen.dart';
import '../../../routes/app_pages.dart';

class IntroPageModel {
  const IntroPageModel({
    required this.title,
    required this.message,
    required this.image,
    this.showHand = false,
  });

  final String title;
  final String message;
  final AssetGenImage image;

  final bool showHand;
}

class IntroController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final PageController pageController = PageController();

  late final AnimationController animationController;

  final RxInt currentIndex = 0.obs;

  final RxBool isFinishing = false.obs;

  final List<IntroPageModel> pages = [
    IntroPageModel(
      title: "Track Every Step You Take",
      message:
          "Count your steps, distance, calories and active time automatically, "
          "even when the app is closed.",
      image: Assets.images.intro1Large,
    ),
    IntroPageModel(
      title: "See Your Progress Clearly",
      message:
          "Daily, weekly, monthly and yearly charts show how active you really are.",
      image: Assets.images.intro2Large,
      showHand: true,
    ),
    IntroPageModel(
      title: "Set A Goal For Every Day",
      message:
          "Choose a step goal for each day and keep your streak alive.",
      image: Assets.images.intro3Large,
      showHand: true,
    ),
    IntroPageModel(
      title: "Earn Medals As You Go",
      message:
          "Unlock achievements for steps, streaks, completed goals and distance.",
      image: Assets.images.intro4Large,
    ),
  ];

  int get lastIndex => pages.length - 1;

  bool get isLastPage => currentIndex.value == lastIndex;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void onReady() {
    super.onReady();
    onPageChanged(0);
  }

  @override
  void onClose() {
    animationController.dispose();
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    animationController
      ..reset()
      ..forward();
  }

  Future<void> onTapNext() async {
    if (isLastPage) {
      await finish();
      return;
    }

    await animateToPage(currentIndex.value + 1);
  }

  Future<void> animateToPage(int index) async {
    if (!pageController.hasClients || index > lastIndex) {
      return;
    }

    await pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> onTapSkip() => finish();

  Future<void> finish() async {
    if (isFinishing.value) {
      return;
    }

    isFinishing.value = true;
    // Cờ hoàn tất được đặt ở cuối onboarding, không đặt ở đây — nếu người dùng
    // thoát giữa chừng thì lần mở sau vẫn phải nhập lại thông tin cơ thể.
    await Get.offAllNamed(Routes.ONBOARDING);
  }
}
