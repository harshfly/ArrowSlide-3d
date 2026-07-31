import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../config.dart';

/// Persists user data using SharedPreferences.
class StorageService {
  static const String _userDataKey = 'arrowslide_user_data';
  static StorageService? _instance;
  late SharedPreferences _prefs;
  late UserData _userData;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUserData();
  }

  void _loadUserData() {
    final jsonStr = _prefs.getString(_userDataKey);
    if (jsonStr != null) {
      _userData = UserData.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } else {
      _userData = UserData();
    }
  }

  UserData get userData => _userData;

  Future<void> saveUserData() async {
    await _prefs.setString(_userDataKey, jsonEncode(_userData.toJson()));
  }

  Future<void> unlockLevel(int levelId) async {
    _userData.unlockedLevels.add(levelId);
    await saveUserData();
  }

  Future<void> completeLevel(int levelId, int moves, int stars) async {
    // Unlock next level
    if (levelId < GameConfig.totalLevels) {
      _userData.unlockedLevels.add(levelId + 1);
    }

    // Save best moves (only if better)
    final current = _userData.bestMoves[levelId];
    if (current == null || moves < current) {
      _userData.bestMoves[levelId] = moves;
    }

    // Save best star rating (only if better)
    final currentStars = _userData.starRatings[levelId];
    if (currentStars == null || stars > currentStars) {
      _userData.starRatings[levelId] = stars;
    }

    // Award coins
    final coinReward = GameConfig.levelCompleteBaseCoins + (stars * GameConfig.coinsPerStar);
    _userData.coins += coinReward;

    // Track completed levels count for interstitial ads
    _userData.completedLevelsCount++;

    await saveUserData();
  }

  /// Returns total coins earned from level completion.
  int calculateLevelReward(int stars) {
    return GameConfig.levelCompleteBaseCoins + (stars * GameConfig.coinsPerStar);
  }

  Future<void> addCoins(int amount) async {
    _userData.coins += amount;
    await saveUserData();
  }

  Future<void> spendCoins(int amount) async {
    _userData.coins = (_userData.coins - amount).clamp(0, 999999);
    await saveUserData();
  }

  Future<void> addHint() async {
    _userData.hints++;
    await saveUserData();
  }

  Future<void> useHint() async {
    if (_userData.hints > 0) {
      _userData.hints--;
      await saveUserData();
    }
  }

  /// Claim daily reward. Returns the reward details.
  Future<Map<String, dynamic>> claimDailyReward() async {
    final reward = _userData.claimDailyReward();
    await saveUserData();
    return reward;
  }

  /// Whether the player should see an interstitial ad after this level.
  bool shouldShowInterstitial() {
    return _userData.completedLevelsCount > 0 &&
        _userData.completedLevelsCount % GameConfig.interstitialFrequency == 0;
  }

  Future<void> updateSettings(UserSettings settings) async {
    _userData = UserData(
      unlockedLevels: _userData.unlockedLevels,
      bestMoves: _userData.bestMoves,
      starRatings: _userData.starRatings,
      coins: _userData.coins,
      hints: _userData.hints,
      completedLevelsCount: _userData.completedLevelsCount,
      settings: settings,
      dailyRewardDay: _userData.dailyRewardDay,
      lastDailyRewardDate: _userData.lastDailyRewardDate,
    );
    await saveUserData();
  }

  Future<void> resetProgress() async {
    _userData = UserData();
    await saveUserData();
  }
}
