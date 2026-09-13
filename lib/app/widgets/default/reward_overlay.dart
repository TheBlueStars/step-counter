import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/colors.gen.dart';
import '../../data/models/enums/reward_type.dart';
import 'reward_bottom_section.dart';

class RewardOverlay extends StatefulWidget {
  const RewardOverlay({
    super.key,
    required this.rewardType,
    this.title,
    this.description,
    this.rewardContentBuilder,
    this.backgroundColor,
    this.onCompleted,
    this.onTapPrimary,
    this.autoSkip = false,
    this.durationMs = 6000,
  });

  final RewardType rewardType;
  final String? title;
  final String? description;

  /// Nội dung ở giữa vòng sáng. Nhận callback để báo hiệu hiệu ứng đã chạy
  /// xong — lúc đó phần chữ và nút mới hiện ra.
  final Widget Function(VoidCallback onCompleted)? rewardContentBuilder;

  final Color? backgroundColor;
  final VoidCallback? onCompleted;
  final VoidCallback? onTapPrimary;
  final bool autoSkip;
  final int durationMs;

  /// Tỉ lệ giữa phần nội dung ở giữa và cạnh của vòng sáng.
  static const double _contentRatio = .4;

  @override
  State<RewardOverlay> createState() => _RewardOverlayState();
}

class _RewardOverlayState extends State<RewardOverlay> {
  bool _contentCompleted = false;

  /// Với huy hiệu thì phải đợi lật xong mới hiện chữ, để người dùng tập trung
  /// vào hiệu ứng trước.
  bool get _showBottom =>
      !widget.rewardType.isAchievement || _contentCompleted;

  @override
  void initState() {
    super.initState();

    if (!widget.autoSkip) {
      return;
    }

    Future.delayed(Duration(milliseconds: widget.durationMs), () {
      if (!mounted) {
        return;
      }

      widget.onCompleted?.call();
    });
  }

  void _onContentCompleted() {
    if (_contentCompleted || !mounted) {
      return;
    }

    setState(() => _contentCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color:
            widget.backgroundColor ??
            ColorName.neutralBlack.withValues(alpha: .7),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Vòng sáng lấy theo cạnh ngắn để không tràn trên máy hẹp.
              final double ring = math.min(
                constraints.maxWidth,
                constraints.maxHeight * .5,
              );

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRing(ring),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showBottom
                        ? _buildBottom()
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRing(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                Assets.lottie.bgReward.path,
                fit: BoxFit.cover,
                frameRate: FrameRate.max,
              ),
            ),
          ),
          SizedBox.square(
            dimension: size * RewardOverlay._contentRatio,
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final builder = widget.rewardContentBuilder;
    if (builder != null) {
      return builder(_onContentCompleted);
    }

    final lottie = widget.rewardType.lottie;
    if (lottie == null) {
      return const SizedBox.shrink();
    }

    return Lottie.asset(lottie.path, fit: BoxFit.contain);
  }

  Widget _buildBottom() {
    return RewardBottomSection(
      title: widget.title ?? widget.rewardType.title,
      description: widget.description ?? widget.rewardType.description,
      showActions: !widget.autoSkip,
      primaryText: "Keep It Up",
      onTapPrimary: widget.onTapPrimary,
    );
  }
}
