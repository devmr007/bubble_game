import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controller/game_controller.dart';

class WinDialog extends StatelessWidget {
  const WinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = GameController.to;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(28),
        decoration: AppStyles.gameCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.buttonGold,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coinGold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 48,
              ),
            ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

            const SizedBox(height: 16),
            Text(AppStrings.victory, style: AppStyles.h1),
            const SizedBox(height: 16),

            // Animated 3 Stars Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final hasStar = index < gameController.stars.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child:
                      Icon(
                            Icons.star_rounded,
                            size: 46,
                            color: hasStar
                                ? AppColors.starActive
                                : AppColors.starInactive,
                          )
                          .animate()
                          .scale(
                            delay: (300 + index * 200).ms,
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          )
                          .shimmer(
                            delay: (900 + index * 200).ms,
                            duration: 800.ms,
                          ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Score and Coin Reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Final Score', style: AppStyles.bodyMedium),
                      Text(
                        '${gameController.score.value}',
                        style: AppStyles.h2.copyWith(color: AppColors.coinGold),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.reward, style: AppStyles.bodyMedium),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: AppColors.coinGold,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${gameController.levelData.coinReward}',
                            style: AppStyles.h3.copyWith(
                              color: AppColors.coinGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (gameController.levelData.levelNumber < 10)
              CustomButton(
                text: AppStrings.nextLevel,
                icon: Icons.skip_next_rounded,
                gradient: AppColors.buttonSuccess,
                onPressed: gameController.nextLevel,
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Replay',
                    icon: Icons.replay_rounded,
                    gradient: AppColors.buttonOrange,
                    onPressed: gameController.restartGame,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Levels',
                    icon: Icons.grid_view_rounded,
                    gradient: AppColors.buttonCyan,
                    onPressed: gameController.exitToLevels,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
