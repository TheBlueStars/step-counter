import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'app/services/achievement_service.dart';
import 'app/services/step_record_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Get.putAsync(() => StepRecordService().init(), permanent: true);
  await Get.putAsync(() => AchievementService().init(), permanent: true);

  runApp(const App());

  FlutterNativeSplash.remove();
}
