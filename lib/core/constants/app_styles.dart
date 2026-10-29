import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppStyles {
  // Headings
  static TextStyle get gameTitle => GoogleFonts.fredoka(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textLight,
    letterSpacing: 1.2,
  );

  static TextStyle get h1 => GoogleFonts.fredoka(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static TextStyle get h2 => GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static TextStyle get h3 => GoogleFonts.fredoka(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle get buttonText => GoogleFonts.fredoka(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.8,
  );

  static TextStyle get scoreText => GoogleFonts.fredoka(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.coinGold,
  );

  // Card & Container Decorations
  static BoxDecoration gameCard = BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration glowingBox(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color, width: 2),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ],
  );
}
