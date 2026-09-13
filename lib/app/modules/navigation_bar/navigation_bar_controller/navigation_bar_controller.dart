import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/enums/medal.dart';
import '../../../data/models/enums/reward_type.dart';
import '../../../services/achievement_service.dart';
import '../../../utils/dialog_utils.dart';
import '../../../widgets/coin_flip_widget.dart';
import '../navigation_bar_argument/navigation_bar_argument.dart';

class NavigationBarController extends GetxController {
  final PageController pageController = PageController();
  final Rx<NavigationPage> _page = Rx(.home);

  final AchievementService _achievements = AchievementService.to;

  /// Chặn mở chồng dialog khi nhiều huy hiệu được mở khoá cùng lúc.
  bool _isRevealing = false;

  NavigationPage get page => _page.value;

  @override
  void onReady() {
    super.onReady();

    // Huy hiệu có thể đã được mở khoá trong lúc app khởi động, trước khi màn
    // hình này tồn tại — nên xử lý hàng chờ hiện có trước rồi mới lắng nghe.
    _revealPendingMedals();
    ever(_achievements.newlyUnlocked, (_) => _revealPendingMedals());
  }

  Future<void> changePage(NavigationPage page) async {
    if (this.page == page) {
      return;
    }
    _page.value = page;
    await pageController.animateToPage(
      page.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Lần lượt bật popup cho từng huy hiệu vừa mở khoá rồi dọn hàng chờ.
  Future<void> _revealPendingMedals() async {
    if (_isRevealing || _achievements.newlyUnlocked.isEmpty) {
      return;
    }

    _isRevealing = true;
    try {
      while (_achievements.newlyUnlocked.isNotEmpty) {
        final medals = List<MedalType>.from(_achievements.newlyUnlocked);
        _achievements.clearNewlyUnlocked();

        for (final medal in medals) {
          await showMedalReward(medal);
        }
      }
    } finally {
      _isRevealing = false;
    }
  }

  /// Overlay phần thưởng huy hiệu: vòng sáng xoay, huy hiệu lật ra ở giữa, chữ
  /// và nút chỉ hiện sau khi lật xong.
  static Future<void> showMedalReward(MedalType medal) {
    return DialogUtils.showReward(
      rewardType: RewardType.achievement,
      description: medal.title,
      rewardContentBuilder: (onCompleted) => CoinFlipWidget(
        medalTypes: [medal],
        onCompleted: onCompleted,
      ),
    );
  }
}
