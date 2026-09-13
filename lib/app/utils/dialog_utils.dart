import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/enums/reward_type.dart';
import '../widgets/default/reward_overlay.dart';

class DialogUtils {
  DialogUtils._();

  static const String _rewardDialogName = "reward_dialog";

  static Future<void> _rewardQueue = Future.value();

  static Future<void> get rewardQueue => _rewardQueue;

  static Future<void> showReward({
    required RewardType rewardType,
    String? title,
    String? description,
    Widget Function(VoidCallback onCompleted)? rewardContentBuilder,
    Color? backgroundColor,
    VoidCallback? onCompleted,
    VoidCallback? onTapPrimary,
    bool autoSkip = false,
    int durationMs = 6000,
  }) async {
    final Future<void> previous = _rewardQueue;
    final Completer<void> current = Completer<void>();
    _rewardQueue = current.future;

    await previous;

    try {
      await Get.dialog(
        RewardOverlay(
          rewardType: rewardType,
          title: title,
          description: description,
          rewardContentBuilder: rewardContentBuilder,
          backgroundColor: backgroundColor,
          autoSkip: autoSkip,
          durationMs: durationMs,
          onTapPrimary: onTapPrimary ?? _close,
          onCompleted: () {
            _close();
            onCompleted?.call();
          },
        ),
        barrierColor: Colors.transparent,
        useSafeArea: false,
        name: _rewardDialogName,
      );
    } finally {
      current.complete();
    }
  }

  /// Đóng đúng dialog phần thưởng, tránh đóng nhầm màn hình bên dưới khi
  /// callback được gọi trễ.
  static void _close() =>
      Get.until((route) => route.settings.name != _rewardDialogName);
}
