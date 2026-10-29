class AppConstants {
  static const int totalLevels = 10;
  static const int defaultStartingCoins = 100;
  static const int coinsPerLevelBase = 50;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String leaderboardCollection = 'leaderboard';

  // Game Grid Physics & Dimensions
  static const int gridCols = 8;
  static const int maxGridRows = 12;
  static const double bubbleRadius = 20.0;
  static const double bubbleSpeed = 900.0;
  static const int minMatchCount = 3;
}
