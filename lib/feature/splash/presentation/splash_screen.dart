import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/bubble_background.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put or find SplashController
    Get.put(SplashController());

    return Scaffold(
      body: BubbleBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bubble Logo with multiple glowing orbiting bubbles
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Ring
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Main Bubble
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.bubblePink,
                          AppColors.bubblePurple,
                          AppColors.bubbleBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Sheen reflection
                        Positioned(
                          top: 18,
                          left: 24,
                          child: Container(
                            width: 32,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.sports_esports_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.92, 0.92),
                        end: const Offset(1.06, 1.06),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      ),
                ],
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.5, 0.5)),

              const SizedBox(height: 36),

              // Game Title
              Text(
                AppStrings.appName.toUpperCase(),
                style: AppStyles.gameTitle.copyWith(
                  fontSize: 32,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              Text(
                AppStrings.appTagline,
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.1,
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

              const SizedBox(height: 48),

              // Loading Progress
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    backgroundColor: AppColors.cardBgElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

