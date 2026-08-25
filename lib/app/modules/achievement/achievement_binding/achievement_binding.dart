import 'package:get/get.dart';
import '../achievement_controller/achievement_controller.dart';

class AchievementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AchievementController>(
      () => AchievementController(),
    );
  }
}
