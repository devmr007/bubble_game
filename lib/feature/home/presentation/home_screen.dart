import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/bubble_background.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final authController = AuthController.to;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Obx(() {
          final user = authController.currentUser.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  (user?.displayName.isNotEmpty == true)
                      ? user!.displayName[0].toUpperCase()
                      : 'P',
                  style: AppStyles.h3.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.displayName ?? 'Player',
                    style: AppStyles.h3.copyWith(fontSize: 16),
                  ),
                  Text(
                    'Level ${user?.currentLevel ?? 1}',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Game Hero Mascot Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 20,
                    ),
                    decoration: AppStyles.gameCard,
                    child: Column(
                      children: [
                        // Animated bouncing Bubble
                        Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.bubblePink,
                                    AppColors.bubblePurple,
                                    AppColors.bubbleCyan,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 30,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.bubble_chart_rounded,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.94, 0.94),
                              end: const Offset(1.06, 1.06),
                              duration: 1800.ms,
                              curve: Curves.easeInOut,
                            ),

                        const SizedBox(height: 20),
                        Text(
                          AppStrings.appName,
                          style: AppStyles.gameTitle.copyWith(fontSize: 28),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '10 Exciting Levels to Conquer!',
                          style: AppStyles.bodyMedium,
                        ),

                        const SizedBox(height: 28),

                        // Big Play Button
                        Obx(
                          () => CustomButton(
                            text:
                                'PLAY LEVEL ${authController.currentUser.value?.currentLevel ?? 1}',
                            icon: Icons.play_arrow_rounded,
                            height: 60,
                            gradient: AppColors.buttonSuccess,
                            onPressed: homeController.playCurrentLevel,
                          ).animate().shimmer(delay: 2000.ms, duration: 1200.ms),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Stats Row
                  Obx(() {
                    final user = authController.currentUser.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star_rounded,
                            iconColor: AppColors.starActive,
                            title: 'Stars Earned',
                            value: '${user?.totalStars ?? 0} / 30',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.emoji_events_rounded,
                            iconColor: AppColors.coinGold,
                            title: 'High Score',
                            value: '${user?.highScore ?? 0}',
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),

                  // Levels Shortcut Card
                  InkWell(
                    onTap: homeController.openLevelSelect,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: AppStyles.gameCard,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              color: AppColors.primaryLight,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Level Progression', style: AppStyles.h3),
                                Obx(
                                  () => Text(
                                    'Level ${authController.currentUser.value?.currentLevel ?? 1} of 10 unlocked',
                                    style: AppStyles.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white54,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: AppStyles.gameCard,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(title, style: AppStyles.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: AppStyles.h2.copyWith(fontSize: 18)),
        ],
      ),
    );
  }
}
