import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Mascot / Bubble Icon with Glow
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.bubblePink, AppColors.bubblePurple, AppColors.bubbleCyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.bubble_chart_rounded,
              size: 54,
              color: Colors.white,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.05, 1.05),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 18),
        Text(
          title,
          style: AppStyles.h1.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppStyles.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
      ],
    );
  }
}

