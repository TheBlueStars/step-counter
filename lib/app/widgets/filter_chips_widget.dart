import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/generated/colors.gen.dart';
import 'package:project/generated/text_styles.gen.dart';

import 'scale_tap_widget.dart';

class FilterChipsWidget<T> extends StatefulWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T item) labelOf;
  final void Function(T item)? onTap;
  final Color? activeColor;
  final Color? inactiveColor;

  const FilterChipsWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.labelOf,
    this.onTap,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<FilterChipsWidget<T>> createState() => _FilterChipsWidgetState<T>();
}

class _FilterChipsWidgetState<T> extends State<FilterChipsWidget<T>> {
  final List<GlobalKey> _chipKeys = [];

  List<double> _widths = const [];

  double get _spacing => 8;

  double get _radius => 24;

  Color get _activeColor => widget.activeColor ?? ColorName.primary100;

  Color get _inactiveColor => widget.inactiveColor ?? ColorName.primary20;

  bool get _hasMeasured => _widths.length == widget.items.length;

  int get _selectedIndex => widget.items.indexOf(widget.selectedItem);

  double get _indicatorStart {
    var start = 0.0;
    for (var index = 0; index < _selectedIndex; index++) {
      start += _widths[index] + _spacing;
    }

    return start;
  }

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didUpdateWidget(covariant FilterChipsWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length == widget.items.length) {
      return;
    }

    _widths = const [];
    _syncKeys();
  }

  void _syncKeys() {
    _chipKeys
      ..clear()
      ..addAll(List.generate(widget.items.length, (_) => GlobalKey()));
  }

  void _measureAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final widths = _chipKeys
          .map((key) => key.currentContext?.size?.width ?? 0)
          .toList();

      if (widths.any((width) => width == 0) || listEquals(widths, _widths)) {
        return;
      }

      setState(() => _widths = widths);
    });
  }

  @override
  Widget build(BuildContext context) {
    _measureAfterLayout();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Stack(
        children: [
          _buildTrackRow(),
          if (_hasMeasured && _selectedIndex >= 0) _buildIndicator(),
          _buildLabelRow(),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return AnimatedPositionedDirectional(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      start: _indicatorStart,
      top: 0,
      bottom: 0,
      width: _widths[_selectedIndex],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _activeColor,
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }

  Widget _buildTrackRow() {
    return Row(
      spacing: _spacing,
      children: List.generate(widget.items.length, _buildTrackChip),
    );
  }

  Widget _buildLabelRow() {
    return Row(
      spacing: _spacing,
      children: List.generate(widget.items.length, _buildLabelChip),
    );
  }

  Widget _buildTrackChip(int index) {
    return Container(
      key: _chipKeys[index],
      padding: _chipPadding,
      decoration: BoxDecoration(
        color: _trackColor(index),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Opacity(opacity: 0, child: _buildLabel(index)),
    );
  }

  Widget _buildLabelChip(int index) {
    final T item = widget.items[index];

    return ScaleTapWidget(
      onTap: widget.onTap == null ? null : () => widget.onTap!(item),
      child: Container(
        padding: _chipPadding,
        color: Colors.transparent,
        child: _buildLabel(index),
      ),
    );
  }

  Widget _buildLabel(int index) {
    return TnmText.body(
      widget.labelOf(widget.items[index]),
    ).semiBold.copyWith(color: ColorName.neutralWhite);
  }

  EdgeInsets get _chipPadding =>
      EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  Color _trackColor(int index) {
    if (!_hasMeasured && index == _selectedIndex) {
      return _activeColor;
    }

    return _inactiveColor;
  }
}
