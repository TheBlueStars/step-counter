import 'package:get/get.dart';
import 'package:project/app/routes/app_pages.dart';

class HomeController extends GetxController {
  void goToStatistical(){
    Get.toNamed(Routes.STATISTICAL);
  }
}
