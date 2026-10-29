import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/bubble_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    final authController = AuthController.to;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.navProfile, style: AppStyles.h1)),
      body: BubbleBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveContainer(
              child: Obx(() {
                final user = authController.currentUser.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // User Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppStyles.gameCard,
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  (user?.displayName.isNotEmpty == true)
                                      ? user!.displayName[0].toUpperCase()
                                      : 'P',
                                  style: AppStyles.h1.copyWith(fontSize: 34),
                                ),
                              ),
                              GestureDetector(
                                onTap: profileController.showEditNameDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.displayName ?? 'Player',
                            style: AppStyles.h2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.isGuest == true
                                ? 'Guest Account'
                                : (user?.email ?? ''),
                            style: AppStyles.bodySmall,
                          ),
                          if (user?.isGuest == true) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.warning,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Sign in anytime to backup your coins and levels to the cloud',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats Grid
                    Text('Player Statistics', style: AppStyles.h2),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatTile(
                          icon: Icons.monetization_on,
                          color: AppColors.coinGold,
                          label: AppStrings.coins,
                          value: '${user?.coins ?? 0}',
                        ),
                        _StatTile(
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.starActive,
                          label: AppStrings.currentLevel,
                          value: '${user?.currentLevel ?? 1} / 10',
                        ),
                        _StatTile(
                          icon: Icons.star_rounded,
                          color: AppColors.starActive,
                          label: AppStrings.totalStars,
                          value: '${user?.totalStars ?? 0}',
                        ),
                        _StatTile(
                          icon: Icons.military_tech_rounded,
                          color: AppColors.bubbleCyan,
                          label: AppStrings.highScores,
                          value: '${user?.highScore ?? 0}',
                        ),
                        _StatTile(
                          icon: Icons.sports_esports_rounded,
                          color: AppColors.primaryLight,
                          label: 'Games Played',
                          value: '${user?.gamesPlayed ?? 0}',
                        ),
                        _StatTile(
                          icon: Icons.trending_up_rounded,
                          color: AppColors.success,
                          label: 'Win Rate',
                          value: '${(user?.winRate ?? 0).toStringAsFixed(1)}%',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Sign Out Button
                    CustomButton(
                      text: AppStrings.signOut,
                      icon: Icons.logout_rounded,
                      gradient: AppColors.buttonDanger,
                      onPressed: profileController.signOut,
                    ),

                    const SizedBox(height: 24),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppStyles.gameCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: AppStyles.h2.copyWith(fontSize: 18)),
        ],
      ),
    );
  }
}
