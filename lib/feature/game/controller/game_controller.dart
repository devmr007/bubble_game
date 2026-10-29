import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../auth/controller/auth_controller.dart';
import '../../levels/model/level_data.dart';
import '../flame/bubble_shooter_game.dart';

class GameController extends GetxController {
  static GameController get to => Get.find();

  late LevelData levelData;
  late BubbleShooterGame flameGame;

  final RxInt score = 0.obs;
  final RxInt movesLeft = 0.obs;
  final RxInt stars = 0.obs;
  final RxBool isGameOver = false.obs;
  final RxBool isGameWon = false.obs;
  final RxBool isPaused = false.obs;
  final RxString gameOverReason = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final levelNum = args?['level'] as int? ?? 1;
    levelData = LevelData.getLevel(levelNum);
    _initLevel();
  }

  void _initLevel() {
    score.value = 0;
    movesLeft.value = levelData.moveLimit;
    stars.value = 0;
    isGameOver.value = false;
    isGameWon.value = false;
    isPaused.value = false;
    gameOverReason.value = '';

    flameGame = BubbleShooterGame(
      levelData: levelData,
      onScoreUpdated: addScore,
      onMoveUsed: useMove,
      onLevelWon: handleLevelWon,
      onLevelLost: handleLevelLost,
    );
  }

  void addScore(int points) {
    score.value += points;
    _calculateStars();
  }

  void _calculateStars() {
    if (score.value >= levelData.threeStarScore) {
      stars.value = 3;
    } else if (score.value >= levelData.twoStarScore) {
      stars.value = 2;
    } else if (score.value >= levelData.oneStarScore) {
      stars.value = 1;
    } else {
      stars.value = 0;
    }
  }

  void useMove() {
    if (movesLeft.value > 0) {
      movesLeft.value -= 1;
      if (movesLeft.value == 0 && !isGameWon.value) {
        // Delayed check in case the last bullet clears the grid
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!isGameWon.value) {
            handleLevelLost('You ran out of bubbles!');
          }
        });
      }
    }
  }

  void handleLevelWon() {
    if (isGameWon.value || isGameOver.value) return;
    isGameWon.value = true;

    // Remaining moves give bonus score
    final bonus = movesLeft.value * 150;
    score.value += bonus;
    _calculateStars();
    if (stars.value == 0) stars.value = 1; // Minimum 1 star for clearing

    // Record progress with AuthController (Firestore / local)
    AuthController.to.recordGameCompletion(
      level: levelData.levelNumber,
      stars: stars.value,
      coinsWon: levelData.coinReward,
      score: score.value,
    );
  }

  void handleLevelLost(String reason) {
    if (isGameOver.value || isGameWon.value) return;
    isGameOver.value = true;
    gameOverReason.value = reason;
  }

  void pauseGame() {
    isPaused.value = true;
    flameGame.pauseEngine();
  }

  void resumeGame() {
    isPaused.value = false;
    flameGame.resumeEngine();
  }

  void restartGame() {
    isPaused.value = false;
    isGameOver.value = false;
    isGameWon.value = false;
    _initLevel();
    update();
  }

  void nextLevel() {
    final nextLevelNum = levelData.levelNumber + 1;
    if (nextLevelNum <= 10) {
      levelData = LevelData.getLevel(nextLevelNum);
      restartGame();
    } else {
      Get.offNamed(AppRoutes.levels);
    }
  }

  void switchBubbles() {
    if (!isGameOver.value && !isPaused.value && !isGameWon.value) {
      flameGame.switchBubbles();
    }
  }

  void exitToLevels() {
    Get.offNamed(AppRoutes.levels);
  }

  void exitToHome() {
    Get.offAllNamed(AppRoutes.main);
  }
}
