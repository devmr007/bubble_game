import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controller/game_controller.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.danger, width: 2),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.danger,
                size: 48,
              ),
            ).animate().shake(duration: 600.ms),

            const SizedBox(height: 16),
            Text(AppStrings.defeat, style: AppStyles.h1),
            const SizedBox(height: 8),
            Text(
              gameController.gameOverReason.value.isNotEmpty
                  ? gameController.gameOverReason.value
                  : AppStrings.outOfMoves,
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Try Again',
              icon: Icons.refresh_rounded,
              gradient: AppColors.buttonOrange,
              onPressed: gameController.restartGame,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Select Level',
              icon: Icons.grid_view_rounded,
              gradient: AppColors.buttonPurple,
              onPressed: gameController.exitToLevels,
            ),
          ],
        ),
      ),
    );
  }
}
