import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/widgets/bubble_background.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/level_controller.dart';
import '../model/level_data.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levelController = Get.put(LevelController());
    final authController = AuthController.to;

    final isWide = !ResponsiveUtil.isMobile(context);
    final crossAxisCount = isWide ? 4 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Level', style: AppStyles.h1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Obx(
              () => CoinBadge(
                coins: authController.currentUser.value?.coins ?? 0,
              ),
            ),
          ),
        ],
      ),
      body: BubbleBackground(
        child: SafeArea(
          child: Obx(() {
            final user = authController.currentUser.value;
            return GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtil.horizontalPadding(context),
                vertical: 20,
              ),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: levelController.levels.length,
              itemBuilder: (context, index) {
                final level = levelController.levels[index];
                final isUnlocked =
                    (user?.unlockedLevels.contains(level.levelNumber) ??
                        false) ||
                    level.levelNumber <= (user?.currentLevel ?? 1);
                final stars =
                    user?.levelStars[level.levelNumber.toString()] ?? 0;

                return _LevelCard(
                  level: level,
                  isUnlocked: isUnlocked,
                  stars: stars,
                  onTap: () => levelController.startLevel(level.levelNumber),
                ).animate().fadeIn(delay: (index * 50).ms).scale();
              },
            );
          }),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelData level;
  final bool isUnlocked;
  final int stars;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? const LinearGradient(
                  colors: [Color(0xFF3B2F99), Color(0xFF221768)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade900.withValues(alpha: 0.8),
                    Colors.grey.shade800.withValues(alpha: 0.6),
                  ],
                ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isUnlocked
                ? AppColors.primaryLight.withValues(alpha: 0.4)
                : Colors.white10,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isUnlocked) ...[
                const Icon(Icons.lock_rounded, size: 40, color: Colors.white38),
                const SizedBox(height: 10),
                Text(
                  'Level ${level.levelNumber}',
                  style: AppStyles.h3.copyWith(color: Colors.white38),
                ),
              ] else ...[
                // Level Number Circle Badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.buttonPrimary,
                  ),
                  child: Center(
                    child: Text(
                      '${level.levelNumber}',
                      style: AppStyles.gameTitle.copyWith(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  level.title,
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Stars Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (starIdx) {
                    final earned = starIdx < stars;
                    return Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: earned
                          ? AppColors.starActive
                          : AppColors.starInactive,
                    );
                  }),
                ),
                const SizedBox(height: 6),
                // Reward Badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 14,
                      color: AppColors.coinGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${level.coinReward}',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.coinGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
