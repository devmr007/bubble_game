import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CoinBadge extends StatelessWidget {
  final int coins;
  final VoidCallback? onTap;

  const CoinBadge({super.key, required this.coins, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.coinGold.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.buttonGold,
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              coins.toString(),
              style: AppStyles.scoreText.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
