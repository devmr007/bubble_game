import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum BubbleType {
  red,
  blue,
  green,
  yellow,
  purple,
  cyan;

  Color get color {
    switch (this) {
      case BubbleType.red:
        return AppColors.bubbleRed;
      case BubbleType.blue:
        return AppColors.bubbleBlue;
      case BubbleType.green:
        return AppColors.bubbleGreen;
      case BubbleType.yellow:
        return AppColors.bubbleYellow;
      case BubbleType.purple:
        return AppColors.bubblePurple;
      case BubbleType.cyan:
        return AppColors.bubbleCyan;
    }
  }
}

class LevelData {
  final int levelNumber;
  final String title;
  final int rowCount;
  final int moveLimit;
  final int coinReward;
  final List<BubbleType> availableColors;
  final int oneStarScore;
  final int twoStarScore;
  final int threeStarScore;

  const LevelData({
    required this.levelNumber,
    required this.title,
    required this.rowCount,
    required this.moveLimit,
    required this.coinReward,
    required this.availableColors,
    required this.oneStarScore,
    required this.twoStarScore,
    required this.threeStarScore,
  });

  static final List<LevelData> allLevels = [
    const LevelData(
      levelNumber: 1,
      title: 'First Blast',
      rowCount: 3,
      moveLimit: 24,
      coinReward: 50,
      availableColors: [BubbleType.red, BubbleType.blue, BubbleType.green],
      oneStarScore: 500,
      twoStarScore: 1000,
      threeStarScore: 1500,
    ),
    const LevelData(
      levelNumber: 2,
      title: 'Triple Cascade',
      rowCount: 4,
      moveLimit: 22,
      coinReward: 60,
      availableColors: [BubbleType.red, BubbleType.blue, BubbleType.green],
      oneStarScore: 800,
      twoStarScore: 1400,
      threeStarScore: 2000,
    ),
    const LevelData(
      levelNumber: 3,
      title: 'Sunny Splash',
      rowCount: 4,
      moveLimit: 21,
      coinReward: 75,
      availableColors: [BubbleType.red, BubbleType.blue, BubbleType.green, BubbleType.yellow],
      oneStarScore: 1100,
      twoStarScore: 1800,
      threeStarScore: 2500,
    ),
    const LevelData(
      levelNumber: 4,
      title: 'Rainbow Cluster',
      rowCount: 5,
      moveLimit: 20,
      coinReward: 90,
      availableColors: [BubbleType.red, BubbleType.blue, BubbleType.green, BubbleType.yellow],
      oneStarScore: 1400,
      twoStarScore: 2200,
      threeStarScore: 3000,
    ),
    const LevelData(
      levelNumber: 5,
      title: 'Purple Mist',
      rowCount: 5,
      moveLimit: 19,
      coinReward: 110,
      availableColors: [
        BubbleType.red,
        BubbleType.blue,
        BubbleType.green,
        BubbleType.yellow,
        BubbleType.purple
      ],
      oneStarScore: 1700,
      twoStarScore: 2600,
      threeStarScore: 3600,
    ),
    const LevelData(
      levelNumber: 6,
      title: 'Crystal Cavern',
      rowCount: 6,
      moveLimit: 18,
      coinReward: 130,
      availableColors: [
        BubbleType.red,
        BubbleType.blue,
        BubbleType.green,
        BubbleType.yellow,
        BubbleType.purple
      ],
      oneStarScore: 2000,
      twoStarScore: 3000,
      threeStarScore: 4200,
    ),
    const LevelData(
      levelNumber: 7,
      title: 'Cyan Surge',
      rowCount: 6,
      moveLimit: 17,
      coinReward: 160,
      availableColors: [
        BubbleType.red,
        BubbleType.blue,
        BubbleType.green,
        BubbleType.yellow,
        BubbleType.purple,
        BubbleType.cyan
      ],
      oneStarScore: 2300,
      twoStarScore: 3500,
      threeStarScore: 4800,
    ),
    const LevelData(
      levelNumber: 8,
      title: 'Tight Angle',
      rowCount: 7,
      moveLimit: 16,
      coinReward: 190,
      availableColors: [
        BubbleType.red,
        BubbleType.blue,
        BubbleType.green,
        BubbleType.yellow,
        BubbleType.purple,
        BubbleType.cyan
      ],
      oneStarScore: 2600,
      twoStarScore: 4000,
      threeStarScore: 5400,
    ),
    const LevelData(
      levelNumber: 9,
      title: 'Master Fortress',
      rowCount: 7,
      moveLimit: 15,
      coinReward: 230,
      availableColors: [
        BubbleType.red,
        BubbleType.blue,
        BubbleType.green,
        BubbleType.yellow,
        BubbleType.purple,
        BubbleType.cyan
      ],
      oneStarScore: 3000,
      twoStarScore: 4500,
      threeStarScore: 6000,
    ),
    const LevelData(
      levelNumber: 10,
      title: 'Apex Champion',
      rowCount: 8,
      moveLimit: 14,
      coinReward: 300,
      availableColors: [
        BubbleType.red,
        BubbleType.blue,
        BubbleType.green,
        BubbleType.yellow,
        BubbleType.purple,
        BubbleType.cyan
      ],
      oneStarScore: 3500,
      twoStarScore: 5200,
      threeStarScore: 7000,
    ),
  ];

  static LevelData getLevel(int levelNumber) {
    if (levelNumber < 1) return allLevels.first;
    if (levelNumber > allLevels.length) return allLevels.last;
    return allLevels[levelNumber - 1];
  }
}

