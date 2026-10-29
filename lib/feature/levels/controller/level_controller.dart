import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/controller/auth_controller.dart';
import '../model/level_data.dart';

class LevelController extends GetxController {
  static LevelController get to => Get.find();

  final List<LevelData> levels = LevelData.allLevels;

  bool isLevelUnlocked(int levelNumber) {
    final user = AuthController.to.currentUser.value;
    if (user == null) return levelNumber == 1;
    return user.unlockedLevels.contains(levelNumber) || levelNumber <= user.currentLevel;
  }

  int getStarsForLevel(int levelNumber) {
    final user = AuthController.to.currentUser.value;
    if (user == null) return 0;
    return user.levelStars[levelNumber.toString()] ?? 0;
  }

  void startLevel(int levelNumber) {
    if (!isLevelUnlocked(levelNumber)) return;
    Get.toNamed(AppRoutes.game, arguments: {'level': levelNumber});
  }
}

