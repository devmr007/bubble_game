import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controller/game_controller.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = GameController.to;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(28),
        decoration: AppStyles.gameCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Paused', style: AppStyles.h1),
            const SizedBox(height: 24),
            CustomButton(
              text: AppStrings.resume,
              icon: Icons.play_arrow_rounded,
              gradient: AppColors.buttonSuccess,
              onPressed: gameController.resumeGame,
            ),
            const SizedBox(height: 14),
            CustomButton(
              text: AppStrings.restart,
              icon: Icons.refresh_rounded,
              gradient: AppColors.buttonOrange,
              onPressed: gameController.restartGame,
            ),
            const SizedBox(height: 14),
            CustomButton(
              text: 'Exit to Levels',
              icon: Icons.grid_view_rounded,
              gradient: AppColors.buttonCyan,
              onPressed: gameController.exitToLevels,
            ),
          ],
        ),
      ),
    );
  }
}
