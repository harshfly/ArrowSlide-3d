import '../config.dart';

/// Stores user progress, scores, coins, hints, daily rewards, and settings locally.
class UserData {
  final Set<int> unlockedLevels;
  final Map<int, int> bestMoves;        // levelId -> best move count
  final Map<int, int> starRatings;      // levelId -> star count (1-3)
  int coins;
  int hints;
  int completedLevelsCount;             // tracks interstitial ad frequency
  final UserSettings settings;

  // Daily Reward
  int dailyRewardDay;                   // 0-6 cycle index
  String lastDailyRewardDate;           // ISO8601 date string

  UserData({
    Set<int>? unlockedLevels,
    Map<int, int>? bestMoves,
    Map<int, int>? starRatings,
    int? coins,
    int? hints,
    int? completedLevelsCount,
    UserSettings? settings,
    int? dailyRewardDay,
    String? lastDailyRewardDate,
  })  : unlockedLevels = unlockedLevels ?? 
            Set<int>.from(List.generate(GameConfig.initialUnlockedLevels, (i) => i + 1)),
        bestMoves = bestMoves ?? {},
        starRatings = starRatings ?? {},
        coins = coins ?? GameConfig.initialCoins,
        hints = hints ?? GameConfig.initialHints,
        completedLevelsCount = completedLevelsCount ?? 0,
        settings = settings ?? UserSettings(),
        dailyRewardDay = dailyRewardDay ?? 0,
        lastDailyRewardDate = lastDailyRewardDate ?? '';

  bool isLevelUnlocked(int levelId) => unlockedLevels.contains(levelId);

  int totalStars() => starRatings.values.fold(0, (sum, s) => sum + s);

  /// Returns the highest completed level ID.
  int get currentProgress {
    final normalLevels = starRatings.keys.where((id) => id != 999);
    if (normalLevels.isEmpty) return 0;
    return normalLevels.reduce((a, b) => a > b ? a : b);
  }

  /// Check if daily reward is available today.
  bool get isDailyRewardAvailable {
    if (lastDailyRewardDate.isEmpty) return true;
    final lastDate = DateTime.tryParse(lastDailyRewardDate);
    if (lastDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
    return today.isAfter(last);
  }

  /// Claim daily reward. Returns the reward map.
  Map<String, dynamic> claimDailyReward() {
    final reward = GameConfig.dailyRewards[dailyRewardDay % GameConfig.dailyRewardCycleDays];
    coins += (reward['coins'] as int?) ?? 0;
    hints += (reward['hints'] as int?) ?? 0;
    lastDailyRewardDate = DateTime.now().toIso8601String();
    dailyRewardDay = (dailyRewardDay + 1) % GameConfig.dailyRewardCycleDays;
    return reward;
  }

  Map<String, dynamic> toJson() => {
        'unlockedLevels': unlockedLevels.toList(),
        'bestMoves': bestMoves.map((k, v) => MapEntry(k.toString(), v)),
        'starRatings': starRatings.map((k, v) => MapEntry(k.toString(), v)),
        'coins': coins,
        'hints': hints,
        'completedLevelsCount': completedLevelsCount,
        'settings': settings.toJson(),
        'dailyRewardDay': dailyRewardDay,
        'lastDailyRewardDate': lastDailyRewardDate,
      };

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      unlockedLevels: (json['unlockedLevels'] as List<dynamic>?)
          ?.map((e) => e as int).toSet(),
      bestMoves: (json['bestMoves'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(int.parse(k), v as int)),
      starRatings: (json['starRatings'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(int.parse(k), v as int)),
      coins: json['coins'] as int?,
      hints: json['hints'] as int?,
      completedLevelsCount: json['completedLevelsCount'] as int?,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      dailyRewardDay: json['dailyRewardDay'] as int?,
      lastDailyRewardDate: json['lastDailyRewardDate'] as String?,
    );
  }
}

class UserSettings {
  final bool musicEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool darkTheme;

  UserSettings({
    this.musicEnabled = GameConfig.defaultMusicEnabled,
    this.soundEnabled = GameConfig.defaultSoundEnabled,
    this.vibrationEnabled = GameConfig.defaultVibrationEnabled,
    this.darkTheme = true,
  });

  Map<String, dynamic> toJson() => {
        'musicEnabled': musicEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'darkTheme': darkTheme,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      musicEnabled: json['musicEnabled'] as bool? ?? GameConfig.defaultMusicEnabled,
      soundEnabled: json['soundEnabled'] as bool? ?? GameConfig.defaultSoundEnabled,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? GameConfig.defaultVibrationEnabled,
      darkTheme: json['darkTheme'] as bool? ?? true,
    );
  }

  UserSettings copyWith({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkTheme,
  }) {
    return UserSettings(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}
