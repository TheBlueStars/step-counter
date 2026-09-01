import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../generated/colors.gen.dart';
import '../../generated/text_styles.gen.dart';

class WheelPickerWidget<T> extends StatefulWidget {
  final List<T> items;
  final T selectedItem;
  final ValueChanged<T> onChanged;
  final double? width;
  final double? widthItem;
  final Color? indicatorColor;
  final Color? indicatorTextColor;
  final int visibleItemCount;
  final double perspective;
  final double diameterRatio;
  final bool looping;

  const WheelPickerWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.width,
    this.widthItem,
    this.indicatorColor,
    this.indicatorTextColor,
    this.visibleItemCount = 5,
    this.perspective = 0.01,
    this.diameterRatio = 2,
    this.looping = false,
  });

  @override
  State<WheelPickerWidget<T>> createState() => _WheelPickerWidgetState<T>();
}

class _WheelPickerWidgetState<T> extends State<WheelPickerWidget<T>> {
  static const double _itemHeight = 45;
  static const Duration _scrollDuration = Duration(milliseconds: 300);

  late FixedExtentScrollController _controller;
  late T _selected;

  @override
  void initState() {
    super.initState();
    final index = _indexOf(widget.selectedItem);
    _selected = widget.items[index];
    _controller = FixedExtentScrollController(initialItem: index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WheelPickerWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final itemsChanged = !listEquals(oldWidget.items, widget.items);
    final selectionChanged = widget.selectedItem != oldWidget.selectedItem;
    if (!itemsChanged && !selectionChanged) {
      return;
    }

    final target = _indexOf(widget.selectedItem);
    setState(() => _selected = widget.items[target]);

    if (itemsChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) {
          return;
        }

        if (_controller.selectedItem != target) {
          _controller.jumpToItem(target);
        }
      });
      return;
    }

    if (_controller.selectedItem != target) {
      _controller.animateToItem(
        target,
        duration: _scrollDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  int _indexOf(T item) {
    final index = widget.items.indexOf(item);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? Get.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildIndicator(),
          SizedBox(
            height: _itemHeight * widget.visibleItemCount,
            child: _buildWheel(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Container(
      height: _itemHeight,
      decoration: BoxDecoration(
        color: widget.indicatorColor ?? ColorName.primary20,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildWheel() {
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: _itemHeight,
      perspective: widget.perspective,
      diameterRatio: widget.diameterRatio,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        setState(() => _selected = widget.items[index % widget.items.length]);
        widget.onChanged(_selected);
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.looping ? null : widget.items.length,
        builder: (context, index) {
          final item = widget.items[index % widget.items.length];
          return _buildItem(item, item == _selected);
        },
      ),
    );
  }

  Widget _buildItem(T value, bool isSelected) {
    return Center(
      child: Container(
        width: widget.widthItem,
        alignment: Alignment.center,
        child: TnmText.title("$value").copyWith(
          color: isSelected
              ? (widget.indicatorTextColor ?? ColorName.neutralBlack)
              : ColorName.disabledText,
        ),
      ),
    );
  }
}
