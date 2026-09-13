import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/enums/medal.dart';

class CoinFlipWidget extends StatefulWidget {
  const CoinFlipWidget({
    super.key,
    required this.medalTypes,
    this.size,
    this.duration = const Duration(seconds: 3),
    this.curve = Curves.decelerate,
    this.halfTurns = 6,
    this.autoStart = true,
    this.startDelay = const Duration(milliseconds: 500),
    this.onCompleted,
    this.onPageChanged,
  });

  final List<MedalType> medalTypes;
  final double? size;
  final Duration duration;
  final Curve curve;
  final int halfTurns;
  final bool autoStart;
  final Duration startDelay;
  final VoidCallback? onCompleted;
  final ValueChanged<int>? onPageChanged;

  static const int columns = 3;
  static const int cellsPerPage = columns * columns;

  @override
  State<CoinFlipWidget> createState() => _CoinFlipWidgetState();
}

class _CoinFlipWidgetState extends State<CoinFlipWidget>
    with SingleTickerProviderStateMixin {
  static const double _flipScale = 0.6;
  static const double _horizontalGap = 12;
  static const double _verticalGap = 32;
  static const Duration _stepDuration = Duration(milliseconds: 400);
  static const Duration _stepDelay = Duration(milliseconds: 400);

  late final List<MedalType> _medals = widget.medalTypes.reversed.toList();

  late final MedalType _leadMedal =
      _medals.firstOrNull ?? MedalType.dailySteps1;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _flip = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  final PageController _pageController = PageController();

  final RxInt _shownCount = 0.obs;

  double get _frameWidth => widget.size ?? Get.width;

  double get _frameHeight => _frameWidth * 0.9;

  double get _cellScale =>
      (1 - 2 * _horizontalGap / _frameWidth) / CoinFlipWidget.columns;

  double get _columnStep => _cellScale + _horizontalGap / _frameWidth;

  double get _rowStep => _cellScale + _verticalGap / _frameWidth;

  double get _gridHeight => (_cellScale + 2 * _rowStep) * _frameHeight;

  int get _medalCount => _medals.length;

  int get _pageCount => (_medalCount / CoinFlipWidget.cellsPerPage).ceil();

  int _pageStart(int page) => page * CoinFlipWidget.cellsPerPage;

  int _pageEnd(int page) =>
      min(_medalCount, _pageStart(page) + CoinFlipWidget.cellsPerPage);

  Offset get _flipOffset {
    final shift = (1 - _flipScale) / 2;

    return Offset(shift, shift);
  }

  bool _isShown(int index) => _shownCount.value > index;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onFlipStatus);
    if (!widget.autoStart) {
      return;
    }

    Future.delayed(widget.startDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onFlipStatus);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onFlipStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    _splitOut();
  }

  Future<void> _splitOut() async {
    _shownCount.value = 1;

    await Future.delayed(_stepDelay);

    while (mounted && _shownCount.value < _medalCount) {
      await _turnToPageOf(_shownCount.value);
      _shownCount.value++;
      await Future.delayed(_stepDelay);
    }

    await Future.delayed(_stepDuration);
    if (!mounted) {
      return;
    }

    widget.onCompleted?.call();
  }

  Future<void> _turnToPageOf(int index) async {
    if (!_pageController.hasClients) {
      return;
    }

    final page = index ~/ CoinFlipWidget.cellsPerPage;
    if (page == (_pageController.page?.round() ?? 0)) {
      return;
    }

    await Future.delayed(_stepDuration);

    await _pageController.animateToPage(
      page,
      duration: _stepDuration,
      curve: Curves.easeInOut,
    );
  }

  Offset _cellOffset(int index) {
    final cell = index % CoinFlipWidget.cellsPerPage;

    return Offset(
      (cell % CoinFlipWidget.columns) * _columnStep,
      (cell ~/ CoinFlipWidget.columns) * _rowStep,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_medalCount > 1) {
      return _buildFrame(_buildPages());
    }

    return _buildFrame(
      Transform.scale(scale: _flipScale, child: _buildFlipFace()),
    );
  }

  Widget _buildFrame(Widget child) {
    return OverflowBox(
      minWidth: _frameWidth,
      maxWidth: _frameWidth,
      maxHeight: double.infinity,
      child: child,
    );
  }

  Widget _buildPages() {
    return SizedBox(
      height: _gridHeight,
      child: _pageCount == 1
          ? _buildPage(0)
          : PageView.builder(
              controller: _pageController,
              itemCount: _pageCount,
              onPageChanged: widget.onPageChanged,
              itemBuilder: (context, page) => _buildPage(page),
            ),
    );
  }

  Widget _buildPage(int page) {
    return Obx(
      () => Stack(
        children: [
          if (_isShown(0))
            for (
              int index = _pageEnd(page) - 1;
              index > _pageStart(page);
              index--
            )
              _buildCell(index),
          page == 0 ? _buildLead() : _buildCell(_pageStart(page)),
        ],
      ),
    );
  }

  Widget _buildCell(int index) {
    return AnimatedSlide(
      key: ValueKey(index),
      offset: _isShown(index) ? _cellOffset(index) : Offset.zero,
      duration: _stepDuration,
      child: AnimatedOpacity(
        opacity: _isShown(index) ? 1 : 0,
        duration: _stepDuration,
        child: Transform.scale(
          scale: _cellScale,
          alignment: Alignment.topLeft,
          child: _medals[index].image.image(
            width: _frameWidth,
            height: _frameHeight,
          ),
        ),
      ),
    );
  }

  Widget _buildLead() {
    return AnimatedSlide(
      key: const ValueKey("lead"),
      offset: _isShown(0) ? Offset.zero : _flipOffset,
      duration: _stepDuration,
      child: AnimatedScale(
        scale: _isShown(0) ? _cellScale : _flipScale,
        alignment: Alignment.topLeft,
        duration: _stepDuration,
        child: _buildFlipFace(),
      ),
    );
  }

  Widget _buildFlipFace() {
    return AnimatedBuilder(
      animation: _flip,
      builder: (context, child) {
        final angle = _flip.value * widget.halfTurns * pi;
        final half = (angle / pi).round();

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(half * pi),
            child: half.isOdd
                ? _leadMedal.achievement.backplateImage.image(
                    width: _frameWidth,
                    height: _frameHeight,
                  )
                : _leadMedal.image.image(
                    width: _frameWidth,
                    height: _frameHeight,
                  ),
          ),
        );
      },
    );
  }
}
