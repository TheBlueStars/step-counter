import 'dart:ui' show lerpDouble;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:project/app/data/models/chart_bar.dart';
import 'package:project/app/data/models/enums/activity_metrics.dart';
import 'package:project/app/data/models/enums/period_type.dart';
import 'package:project/app/extensions/chart_bar_extension.dart';
import 'package:project/app/extensions/number_extension.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

import 'summary_chart/bar_shadow_painter.dart';
import 'summary_chart/chart_geometry.dart';
import 'summary_chart/chart_tooltip_bubble.dart';
import 'summary_chart/chart_tooltip_layout.dart';
import 'summary_chart/summary_chart_legend.dart';

class SummaryChart extends StatefulWidget {
  final List<ChartBar> bars;
  final int totalStep;
  final double average;
  final PeriodType period;
  final ActivityMetrics metric;

  const SummaryChart({
    super.key,
    required this.bars,
    required this.totalStep,
    required this.average,
    required this.period,
    required this.metric,
  });

  @override
  State<SummaryChart> createState() => _SummaryChartState();
}

class _SummaryChartState extends State<SummaryChart>
    with SingleTickerProviderStateMixin {
  static const int _titleDivisions = 5;
  static const double _chartHeight = 280;
  static const double _bottomAxisSize = 20;
  static const double _tooltipSpace = 32;
  static const double _barRadius = 4;
  static const Duration _animationDuration = Duration(milliseconds: 450);

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: _animationDuration,
  );

  List<double> _from = const [];
  List<double> _to = const [];
  double _fromMaxY = 0;
  double _toMaxY = 0;
  double _fromAverage = 0;
  double _toAverage = 0;
  int? _touchedIndex;

  List<ChartBar> get bars => widget.bars;

  PeriodType get period => widget.period;

  ActivityMetrics get metric => widget.metric;

  List<double> get _targetValues => bars.map((bar) => bar.value).toList();

  double get _t => Curves.easeOutCubic.transform(_animation.value);

  List<double> get _values => List.generate(
    _to.length,
    (i) => lerpDouble(i < _from.length ? _from[i] : 0, _to[i], _t)!,
  );

  double get _maxY => lerpDouble(_fromMaxY, _toMaxY, _t)!;

  double get _average => lerpDouble(_fromAverage, _toAverage, _t)!;

  double get _leftInterval => _maxY / _titleDivisions;

  double get _chartMaxY =>
      _maxY + _maxY * _tooltipSpace / (_chartHeight - _bottomAxisSize);

  bool _isInsideAxis(double value) => value <= _maxY + _leftInterval / 2;

  double get _barWidth => widget.period.barWidth;

  double _safeMaxY(int total) => total <= 0 ? 1 : total.toDouble();

  double get _leftAxisSize => widget.period.isYear ? 55 : 40;

  @override
  void initState() {
    super.initState();
    _to = _targetValues;
    _from = List.filled(_to.length, 0);
    _fromMaxY = _toMaxY = _safeMaxY(widget.totalStep);
    _toAverage = widget.average;
    _animation.forward();
  }

  @override
  void didUpdateWidget(covariant SummaryChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _targetValues;
    final nextMaxY = _safeMaxY(widget.totalStep);
    if (listEquals(next, _to) &&
        nextMaxY == _toMaxY &&
        widget.average == _toAverage) {
      return;
    }

    final sameLength = next.length == _to.length;
    _touchedIndex = null;
    _from = sameLength ? _values : List.filled(next.length, 0);
    _fromMaxY = sameLength ? _maxY : nextMaxY;
    _fromAverage = sameLength ? _average : 0;
    _to = next;
    _toMaxY = nextMaxY;
    _toAverage = widget.average;
    _animation.forward(from: 0);
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: ColorName.neutralWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorName.borderBackground),
      ),
      child: Column(
        children: [
          SizedBox(height: 16),
          SizedBox(
            height: _chartHeight,
            child: LayoutBuilder(
              builder: (context, constraints) => AnimatedBuilder(
                animation: _animation,
                builder: (_, _) {
                  final values = _values;
                  final geometry = _geometry(constraints.biggest);
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _shadowPainter(values, geometry),
                        ),
                      ),
                      BarChart(
                        _chartData(values, geometry),
                        duration: const Duration(milliseconds: 2),
                      ),
                      ..._buildTooltipOverlay(values, geometry),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          SummaryChartLegend(period: period, metric: metric),
        ],
      ),
    );
  }

  BarChartData _chartData(List<double> values, ChartGeometry geometry) {
    return BarChartData(
      maxY: _chartMaxY,
      minY: 0,
      alignment: BarChartAlignment.spaceBetween,
      barGroups: _buildBars(values, geometry),
      gridData: _buildGrid(),
      titlesData: _buildTitles(),
      borderData: FlBorderData(show: false),
      barTouchData: _buildTouch(),
      extraLinesData: _buildExtraLines(),
    );
  }

  ChartGeometry _geometry(Size size) => ChartGeometry(
    size: size,
    count: bars.length,
    barWidth: _barWidth,
    maxY: _chartMaxY,
    leftInset: _leftAxisSize,
    bottomInset: _bottomAxisSize,
  );

  BarShadowPainter _shadowPainter(List<double> values, ChartGeometry geometry) {
    return BarShadowPainter(
      values: values,
      geometry: geometry,
      topRadius: _barRadius,
      blurSigma: 2,
      colorsShadow: bars.shadowColors(period),
    );
  }

  List<BarChartGroupData> _buildBars(
    List<double> values,
    ChartGeometry geometry,
  ) {
    final gradients = bars.barGradients(period);
    final minFutureValue = geometry.isEmpty
        ? 0.0
        : (2 / geometry.plotHeight) * geometry.maxY;

    return List.generate(bars.length, (i) {
      final isFuture = bars[i].isFuture;
      final hideColumn = period.isDay && isFuture;
      final value = i < values.length ? values[i] : bars[i].value;
      final toY = hideColumn ? 0.0 : (isFuture ? minFutureValue : value);
      return BarChartGroupData(
        x: i,
        barsSpace: 0,
        barRods: [
          BarChartRodData(
            toY: toY,
            width: _barWidth,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_barRadius),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: !hideColumn,
              toY: _maxY,
              color: ColorName.neutralLightGray.withValues(alpha: .2),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradients[i],
            ),
          ),
        ],
      );
    });
  }

  int get _activeIndex => _touchedIndex ?? bars.peakIndex;

  List<Widget> _buildTooltipOverlay(
    List<double> values,
    ChartGeometry geometry,
  ) {
    final index = _activeIndex;
    if (index < 0 || index >= bars.length || geometry.isEmpty) {
      return const [];
    }

    final value = index < values.length ? values[index] : bars[index].value;
    if (value <= 0) {
      return const [];
    }

    final text = metric.titleToolTip(bars[index]);
    final style = TextStyles.caption.copyWith(color: ColorName.secondary50);
    final measure = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final layout = ChartTooltipLayout.resolve(
      geometry: geometry,
      index: index,
      value: value,
      textSize: measure.size,
    );

    return [
      Positioned(
        left: layout.left,
        top: layout.top,
        child: IgnorePointer(
          child: ChartTooltipBubble(
            text: text,
            style: style,
            color: ColorName.extra.extra3,
            layout: layout,
          ),
        ),
      ),
    ];
  }

  FlGridData _buildGrid() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _leftInterval,
      checkToShowHorizontalLine: _isInsideAxis,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: ColorName.neutralGray,
          strokeWidth: 1,
          dashArray: [8, 4],
        );
      },
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _leftInterval,
          reservedSize: _leftAxisSize,
          getTitlesWidget: (value, meta) => _isInsideAxis(value)
              ? SideTitleWidget(
                  meta: meta,
                  space: 12,
                  child: _axisLabel(value.compact),
                )
              : const SizedBox(),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: _bottomAxisSize,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= bars.length) {
              return const SizedBox();
            }

            if (!period.showLabelAt(index, bars.length)) {
              return const SizedBox();
            }

            final label = bars[index].label;
            if (label.isEmpty) {
              return const SizedBox();
            }

            return SideTitleWidget(
              meta: meta,
              space: 4,
              child: _axisLabel(label),
            );
          },
        ),
      ),
    );
  }

  BarTouchData _buildTouch() {
    return BarTouchData(
      handleBuiltInTouches: false,
      touchCallback: _onTouch,
      touchTooltipData: BarTouchTooltipData(
        getTooltipItem: (_, _, _, _) => null,
      ),
    );
  }

  void _onTouch(FlTouchEvent event, BarTouchResponse? response) {
    final touched = event.isInterestedForInteractions
        ? response?.spot?.touchedBarGroupIndex
        : null;
    if (touched == _touchedIndex) {
      return;
    }

    setState(() => _touchedIndex = touched);
  }

  ExtraLinesData _buildExtraLines() {
    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: 0,
          color: ColorName.neutralGray,
          strokeWidth: 1,
          dashArray: [8, 4],
        ),

        HorizontalLine(
          y: _maxY,
          color: ColorName.neutralGray,
          strokeWidth: 1,
          dashArray: [8, 4],
        ),

        HorizontalLine(
          y: _average,
          color: ColorName.primary100,
          strokeWidth: 1.5,
          dashArray: [6, 4],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: TextStyles.description.copyWith(color: ColorName.primary100),
            labelResolver: (_) => metric.textAvgChart(widget.average, period),
          ),
        ),
      ],
    );
  }

  Widget _axisLabel(String text) =>
      TnmText.description(text).copyWith(color: ColorName.neutralGray);
}
