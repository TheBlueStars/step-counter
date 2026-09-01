import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/extensions/date_time_extension.dart';
import 'package:project/app/utils/time_utils.dart';
import 'package:project/app/widgets/calendar/dash_circle_painter.dart';
import 'package:project/app/widgets/calendar/pie_progress_painter.dart';
import 'package:project/app/widgets/default/card_default.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/colors.gen.dart';
import '../../../generated/text_styles.gen.dart';

typedef DayProgressLoader = FutureOr<double?> Function(DateTime day);

class CalendarWidget extends StatefulWidget {
  final DayProgressLoader? progressOf;
  final ValueChanged<DateTime>? onDaySelected;
  final ValueListenable<DateTime?>? progressChangedDay;
  final ValueListenable<DateTime?>? selectDay;
  final ValueListenable<Object?>? reloadProgress;
  final bool showProgressAllDays;

  const CalendarWidget({
    super.key,
    this.progressOf,
    this.onDaySelected,
    this.progressChangedDay,
    this.selectDay,
    this.reloadProgress,
    this.showProgressAllDays = true,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  static const int _yearsRange = 2;

  double get _weekStripHeight => 82;

  Duration get _selectDuration => 250.milliseconds;

  late DateTime _selectedDate = _today;
  final Map<DateTime, double?> _progressByDay = {};

  late final DateTime _minWeekStart = DateTime(
    _today.year - _yearsRange,
    _today.month,
    _today.day,
  ).startOfWeek;

  late final int _totalWeeks =
      _pageForWeek(
        DateTime(
          _today.year + _yearsRange,
          _today.month,
          _today.day,
        ).startOfWeek,
      ) +
      1;

  late final int _currentWeekPage = _pageForWeek(_today.startOfWeek);

  late final PageController _pageController = PageController(
    initialPage: _currentWeekPage,
  );

  late int _currentPage = _currentWeekPage;

  DateTime get _today => DateTime.now().startOfDay;

  int _pageForWeek(DateTime weekStart) =>
      weekStart.difference(_minWeekStart).inDays ~/ 7;

  DateTime _weekStartForPage(int page) =>
      _minWeekStart.add(Duration(days: 7 * page));

  List<DateTime> _daysForPage(int page) {
    final weekStart = _weekStartForPage(page);
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  bool _isFuture(DateTime day) => day.isAfter(_today);

  @override
  void initState() {
    super.initState();
    _loadAround(_currentWeekPage);
    widget.progressChangedDay?.addListener(_onProgressChanged);
    widget.selectDay?.addListener(_onSelectDayRequested);
    widget.reloadProgress?.addListener(_onReloadProgress);
  }

  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressChangedDay != widget.progressChangedDay) {
      oldWidget.progressChangedDay?.removeListener(_onProgressChanged);
      widget.progressChangedDay?.addListener(_onProgressChanged);
    }
    if (oldWidget.selectDay != widget.selectDay) {
      oldWidget.selectDay?.removeListener(_onSelectDayRequested);
      widget.selectDay?.addListener(_onSelectDayRequested);
    }
    if (oldWidget.reloadProgress != widget.reloadProgress) {
      oldWidget.reloadProgress?.removeListener(_onReloadProgress);
      widget.reloadProgress?.addListener(_onReloadProgress);
    }
  }

  @override
  void dispose() {
    widget.progressChangedDay?.removeListener(_onProgressChanged);
    widget.selectDay?.removeListener(_onSelectDayRequested);
    widget.reloadProgress?.removeListener(_onReloadProgress);
    _pageController.dispose();
    super.dispose();
  }

  void _onReloadProgress() {
    _progressByDay.clear();
    _loadAround(_currentPage);
  }

  void _onProgressChanged() {
    final changed = widget.progressChangedDay?.value;
    if (changed == null) {
      return;
    }
    _loadDay(changed.startOfDay);
  }

  void _onSelectDayRequested() {
    final requested = widget.selectDay?.value;
    if (requested == null || _isFuture(requested)) {
      return;
    }

    final day = requested.startOfDay;
    setState(() => _selectedDate = day);

    final page = _pageForWeek(day.startOfWeek);
    if (page != _currentPage) {
      _animateToPage(page);
    }
    _loadDay(day);
  }

  void _loadAround(int page) {
    for (final p in [page - 1, page, page + 1]) {
      if (p >= 0 && p < _totalWeeks) {
        _loadWeek(p);
      }
    }
  }

  Future<void> _loadWeek(int page) async {
    for (final day in _daysForPage(page)) {
      if (_progressByDay.containsKey(day)) {
        continue;
      }
      await _loadDay(day);
    }
  }

  Future<void> _loadDay(DateTime day) async {
    final loader = widget.progressOf;
    if (loader == null || _isFuture(day)) {
      return;
    }

    final value = (await loader(day))?.clamp(0.0, 1.0);
    if (!mounted) {
      return;
    }

    setState(() => _progressByDay[day] = value);
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _loadAround(page);
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectDay(DateTime day) {
    if (_isFuture(day)) {
      return;
    }

    setState(() => _selectedDate = day);
    widget.onDaySelected?.call(day);
  }

  void _previousWeek() {
    if (_currentPage <= 0) {
      return;
    }
    _animateToPage(_currentPage - 1);
  }

  void _nextWeek() {
    if (_currentPage >= _totalWeeks - 1) {
      return;
    }

    _animateToPage(_currentPage + 1);
  }

  void _backToCurrentWeek() {
    setState(() => _selectedDate = _today);
    _animateToPage(_currentWeekPage);
    widget.onDaySelected?.call(_today);
  }

  @override
  Widget build(BuildContext context) {
    return CardDefault(
      padding: EdgeInsets.symmetric(vertical: 12),
      borderRadius: 16,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: _weekStripHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalWeeks,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return Row(
                    children: _daysForPage(index)
                        .map((day) => Expanded(child: _buildDayPill(day)))
                        .toList(),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 12),
          _buildWeekNav(),
        ],
      ),
    );
  }

  Widget _buildWeekNav() {
    final range = _weekStartForPage(_currentPage).weekLabel;
    final isToday = _selectedDate.isToday;
    final isCurrentWeek = _currentPage == _currentWeekPage;
    final showReturn = !isToday || !isCurrentWeek;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        Visibility(
          visible: false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: _buildArrow(
            icon: Assets.svg.icLineReturn.svg(width: 20, height: 20),
            enabled: showReturn,
            onTap: _backToCurrentWeek,
          ),
        ),
        SizedBox(
          width: 225,
          child: Row(
            spacing: 20,
            children: [
              _buildArrow(
                icon: Icon(Icons.chevron_left, color: ColorName.primary100),
                enabled: _currentPage > 0,
                onTap: _previousWeek,
              ),
              Expanded(
                child: TnmText.body(range).semiBold.copyWith(
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  color: ColorName.neutralBlack,
                ),
              ),
              _buildArrow(
                icon: Icon(Icons.chevron_right, color: ColorName.primary100),
                enabled: _currentPage < _totalWeeks - 1,
                onTap: _nextWeek,
              ),
            ],
          ),
        ),
        AnimatedScale(
          scale: showReturn ? 1 : 0,
          duration: 250.milliseconds,
          curve: Curves.easeOutBack,
          child: _buildArrow(
            icon: Assets.svg.icLineReturn.svg(width: 20, height: 20),
            enabled: showReturn,
            onTap: _backToCurrentWeek,
          ),
        ),
      ],
    );
  }

  Widget _buildArrow({
    required Widget icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ScaleTapWidget(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorName.neutralWhite,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 8,
              color: ColorName.neutralBlack.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: icon,
      ),
    );
  }

  CustomPainter? _dayPainter(
    bool isFuture,
    double? progress, {
    bool isSelected = false,
  }) {
    final dashedCircle = DashedCirclePainter(
      color: isSelected ? ColorName.primary100 : ColorName.neutralGray,
      strokeWidth: 1,
    );

    if (progress == null) {
      if (widget.showProgressAllDays) {
        return dashedCircle;
      }
      return null;
    }

    if (isFuture || progress == 0) {
      return dashedCircle;
    }

    return PieProgressPainter(
      progress: progress,
      color: ColorName.primary100,
      trackColor: ColorName.primary100,
      strokeWidth: 0.5,
    );
  }

  Widget _buildDayPill(DateTime day) {
    final isSelected = TimeUtils.isSameDate(_selectedDate, day);
    final isFuture = _isFuture(day);
    final progress = _progressByDay[day];
    final isToday = day.isToday;

    final Color pillColor = isSelected || isToday
        ? ColorName.neutralWhite
        : ColorName.secondary20;
    final Color borderColor = isSelected
        ? ColorName.primary100
        : isToday
        ? ColorName.borderBackground
        : Colors.transparent;
    final Color dayColor = isSelected
        ? ColorName.primary100
        : isToday
        ? ColorName.primary20
        : ColorName.neutralWhite;
    final Color dayTextColor = isSelected
        ? ColorName.neutralWhite
        : isToday
        ? ColorName.primary100
        : ColorName.disabledText;
    final descriptionTextColor = isSelected
        ? ColorName.primary100
        : isToday
        ? ColorName.onColorText
        : ColorName.neutralGray;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final size = width * 0.2;

        return ScaleTapWidget(
          onTap: isFuture ? null : () => _selectDay(day),
          child: AnimatedContainer(
            duration: _selectDuration,
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(64),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              children: [
                SizedBox(height: height * 0.1),

                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _dayPainter(
                      isFuture,
                      progress,
                      isSelected: isSelected,
                    ),
                  ),
                ),

                SizedBox(height: height * 0.04),

                TnmText.description(
                  day.EEE,
                ).copyWith(color: descriptionTextColor, maxLines: 1),

                const Spacer(),

                AnimatedContainer(
                  duration: _selectDuration,
                  curve: Curves.easeOut,
                  width: width * 0.55,
                  height: width * 0.6,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dayColor,
                  ),
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: dayTextColor),
                    duration: _selectDuration,
                    curve: Curves.easeOut,
                    builder: (context, color, child) {
                      return TnmText.title("${day.day}").copyWith(color: color);
                    },
                  ),
                ),

                SizedBox(height: height * 0.06),
              ],
            ),
          ),
        );
      },
    );
  }
}
