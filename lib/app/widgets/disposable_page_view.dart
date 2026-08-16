import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class DisposablePageView<T> extends StatefulWidget {
  final PageController controller;
  final List<T> navPages;
  final bool Function(T page) keepAliveOf;
  final String Function(T page) pageOf;
  final ScrollPhysics? physics;

  const DisposablePageView({
    super.key,
    required this.controller,
    required this.navPages,
    required this.keepAliveOf,
    required this.pageOf,
    this.physics,
  });

  @override
  State<DisposablePageView<T>> createState() => _DisposablePageViewState<T>();
}

class _DisposablePageViewState<T> extends State<DisposablePageView<T>> {
  final Map<int, Key> _keys = {};

  int get _currentIndex =>
      (widget.controller.hasClients ? widget.controller.page : null)?.round() ??
      widget.controller.initialPage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handlePageChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handlePageChange);
    super.dispose();
  }

  void _handlePageChange() => setState(() {});

  GetPage _routeOf(String name) {
    return AppPages.routes.firstWhere((route) => route.name == name);
  }

  Widget? _buildPage(int index) {
    final navPage = widget.navPages[index];
    final route = _routeOf(widget.pageOf(navPage));
    final keepAlive = widget.keepAliveOf(navPage);

    final key = keepAlive
        ? (_keys[index] ??= ValueKey(index))
        : (index == _currentIndex ? (_keys[index] = UniqueKey()) : null);
    if (key == null) return null;

    route.binding?.dependencies();
    return KeyedSubtree(key: key, child: route.page());
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.controller,
      physics: widget.physics,
      children: [
        for (var i = 0; i < widget.navPages.length; i++)
          _buildPage(i) ?? const SizedBox.shrink(),
      ],
    );
  }
}
