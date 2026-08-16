import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../statistical_controller/statistical_controller.dart';

class StatisticalView extends GetView<StatisticalController> {
  const StatisticalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistical'),
      ),
      body: const Center(
        child: Text('Statistical View'),
      ),
    );
  }
}
