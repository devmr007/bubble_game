import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/controller/auth_controller.dart';
import '../../navigation/controller/navigation_controller.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  void playCurrentLevel() {
    final user = AuthController.to.currentUser.value;
    final level = user?.currentLevel ?? 1;
    Get.toNamed(AppRoutes.game, arguments: {'level': level});
  }

  void openLevelSelect() {
    NavigationController.to.changeIndex(1);
  }
}

