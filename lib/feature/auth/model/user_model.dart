import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final int coins;
  final int currentLevel;
  final List<int> unlockedLevels;
  final Map<String, int> levelStars; // e.g. {'1': 3, '2': 2}
  final int highScore;
  final int gamesPlayed;
  final int gamesWon;
  final bool isGuest;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.coins = 100,
    this.currentLevel = 1,
    this.unlockedLevels = const [1],
    this.levelStars = const {},
    this.highScore = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.isGuest = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get totalStars =>
      levelStars.values.fold(0, (total, stars) => total + stars);

  double get winRate =>
      gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    int? coins,
    int? currentLevel,
    List<int>? unlockedLevels,
    Map<String, int>? levelStars,
    int? highScore,
    int? gamesPlayed,
    int? gamesWon,
    bool? isGuest,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      coins: coins ?? this.coins,
      currentLevel: currentLevel ?? this.currentLevel,
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
      levelStars: levelStars ?? this.levelStars,
      highScore: highScore ?? this.highScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'coins': coins,
      'currentLevel': currentLevel,
      'unlockedLevels': unlockedLevels,
      'levelStars': levelStars,
      'highScore': highScore,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'isGuest': isGuest,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Bubble Popper',
      photoUrl: data['photoUrl'],
      coins: (data['coins'] ?? 100) as int,
      currentLevel: (data['currentLevel'] ?? 1) as int,
      unlockedLevels: (data['unlockedLevels'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [1],
      levelStars: (data['levelStars'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ) ??
          {},
      highScore: (data['highScore'] ?? 0) as int,
      gamesPlayed: (data['gamesPlayed'] ?? 0) as int,
      gamesWon: (data['gamesWon'] ?? 0) as int,
      isGuest: data['isGuest'] ?? false,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory UserModel.guest() {
    return UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@bubblegame.app',
      displayName: 'Guest Player',
      isGuest: true,
      coins: 100,
      currentLevel: 1,
      unlockedLevels: const [1],
      levelStars: const {},
    );
  }
}

