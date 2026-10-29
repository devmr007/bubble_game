import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/coin_badge.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../controller/game_controller.dart';

class GameHud extends StatelessWidget {
  const GameHud({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = GameController.to;
    final authController = AuthController.to;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Compact Pause Button
            GestureDetector(
              onTap: gameController.pauseGame,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Moves Left Bubble Counter
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gameController.movesLeft.value <= 3
                        ? AppColors.danger
                        : AppColors.accent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (gameController.movesLeft.value <= 3
                                  ? AppColors.danger
                                  : AppColors.accent)
                              .withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bubble_chart_rounded,
                      color: AppColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${gameController.movesLeft.value}',
                      style: AppStyles.h3.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Level & Score Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LV ${gameController.levelData.levelNumber} ',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '| ${gameController.score.value}',
                      style: AppStyles.bodyLarge.copyWith(
                        color: AppColors.coinGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Coin Badge
            Obx(
              () => CoinBadge(
                coins: authController.currentUser.value?.coins ?? 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
