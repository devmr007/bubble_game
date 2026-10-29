import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/responsive_util.dart';
import '../controller/game_controller.dart';
import 'widgets/game_hud.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/pause_dialog.dart';
import 'widgets/win_dialog.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.put(GameController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ResponsiveUtil.maxContentWidth,
            ),
            child: Stack(
              children: [
                // Flame Game canvas
                GetBuilder<GameController>(
                  builder: (ctrl) => GameWidget(game: ctrl.flameGame),
                ),

                // Top Game HUD
                const Positioned(top: 0, left: 0, right: 0, child: GameHud()),

                // Quick Swap Floating Button at bottom right
                Positioned(
                  bottom: 22,
                  right: 18,
                  child: GestureDetector(
                    onTap: () => gameController.switchBubbles(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.6),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cached_rounded,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'SWAP',
                            style: AppStyles.h3.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Dialog Overlays
                Obx(() {
                  final isPaused = gameController.isPaused.value;
                  final isWon = gameController.isGameWon.value;
                  final isLost = gameController.isGameOver.value;

                  if (isPaused) {
                    return Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      child: const PauseDialog(),
                    );
                  }
                  if (isWon) {
                    return Container(
                      color: Colors.black.withValues(alpha: 0.75),
                      child: const WinDialog(),
                    );
                  }
                  if (isLost) {
                    return Container(
                      color: Colors.black.withValues(alpha: 0.75),
                      child: const GameOverDialog(),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
