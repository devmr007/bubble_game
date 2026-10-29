import 'package:flutter/material.dart';

class AppColors {
  // Brand & Game Palette
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4834D4);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color secondary = Color(0xFFFF7675);
  static const Color accent = Color(0xFF00CEC9);
  static const Color accentGold = Color(0xFFFFD700);

  // Backgrounds
  static const Color background = Color(0xFF130F40);
  static const Color backgroundLight = Color(0xFF1E175C);
  static const Color cardBg = Color(0xFF241B66);
  static const Color cardBgElevated = Color(0xFF302380);

  // Surface & Text
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB2BEC3);
  static const Color textDark = Color(0xFF2D3436);

  // Game UI
  static const Color coinGold = Color(0xFFFFB300);
  static const Color coinShine = Color(0xFFFFE082);
  static const Color starActive = Color(0xFFFFC107);
  static const Color starInactive = Color(0xFF4A4465);
  static const Color success = Color(0xFF00B894);
  static const Color danger = Color(0xFFD63031);
  static const Color warning = Color(0xFFE17055);

  // Bubble Colors
  static const Color bubbleRed = Color(0xFFFF4757);
  static const Color bubbleBlue = Color(0xFF2E86DE);
  static const Color bubbleGreen = Color(0xFF10AC84);
  static const Color bubbleYellow = Color(0xFFFF9F43);
  static const Color bubblePurple = Color(0xFF8854D0);
  static const Color bubbleCyan = Color(0xFF0ABDE3);
  static const Color bubblePink = Color(0xFFFF6B81);

  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1454), Color(0xFF0D0A2C)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F247F), Color(0xFF1F1758)],
  );

  static const LinearGradient buttonPrimary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7C66FF), Color(0xFF563ED6)],
  );

  static const LinearGradient buttonSuccess = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF00E676), Color(0xFF00A854)],
  );

  static const LinearGradient buttonGold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
  );

  static const LinearGradient buttonCyan = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF00CEC9), Color(0xFF0984E3)],
  );

  static const LinearGradient buttonOrange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF7675), Color(0xFFE17055)],
  );

  static const LinearGradient buttonDanger = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF4757), Color(0xFFC0392B)],
  );

  static const LinearGradient buttonGoogle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4285F4), Color(0xFF1967D2)],
  );

  static const LinearGradient buttonPurple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8E44AD), Color(0xFF6C5CE7)],
  );
}
