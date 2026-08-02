import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../config.dart';

/// Persists user data using SharedPreferences with batched/debounced writes.
///
/// All mutations are applied to the in-memory [UserData] immediately,
/// and a single debounced write flushes to disk after [_writeDebounceDuration].
/// This prevents blocking the UI thread on every coin/level update.
class StorageService {
  static const String _userDataKey = 'arrowslide_user_data';
  static const Duration _writeDebounceDuration = Duration(milliseconds: 500);

  static StorageService? _instance;
  late SharedPreferences _prefs;
  late UserData _userData;
  Timer? _writeTimer;
  bool _isDirty = false;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadUserData();
    } catch (e) {
      _debugLog('StorageService init error: $e');
      _userData = UserData();
    }
  }

  void _loadUserData() {
    try {
      final jsonStr = _prefs.getString(_userDataKey);
      if (jsonStr != null) {
        _userData = UserData.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );
      } else {
        _userData = UserData();
      }
    } catch (e) {
      _debugLog('Failed to load user data: $e');
      _userData = UserData();
    }
  }

  UserData get userData => _userData;

  /// Schedule a debounced write to disk.
  void _scheduleSave() {
    _isDirty = true;
    _writeTimer?.cancel();
    _writeTimer = Timer(_writeDebounceDuration, _flushToDisk);
  }

  /// Force an immediate save (e.g., before app goes to background).
  Future<void> saveUserData() async {
    _writeTimer?.cancel();
    await _flushToDisk();
  }

  Future<void> _flushToDisk() async {
    if (!_isDirty) return;
    try {
      final json = jsonEncode(_userData.toJson());
      await _prefs.setString(_userDataKey, json);
      _isDirty = false;
    } catch (e) {
      _debugLog('Failed to save user data: $e');
    }
  }

  Future<void> unlockLevel(int levelId) async {
    _userData.unlockedLevels.add(levelId);
    _scheduleSave();
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
    final coinReward = calculateLevelReward(stars);
    _userData.coins += coinReward;

    // Track completed levels count for interstitial ads
    _userData.completedLevelsCount++;

    _scheduleSave();
  }

  /// Returns total coins earned from level completion.
  int calculateLevelReward(int stars) {
    return GameConfig.levelCompleteBaseCoins +
        (stars * GameConfig.coinsPerStar);
  }

  Future<void> addCoins(int amount) async {
    _userData.coins += amount;
    _scheduleSave();
  }

  Future<void> spendCoins(int amount) async {
    _userData.coins = (_userData.coins - amount).clamp(0, 999999);
    _scheduleSave();
  }

  Future<void> addHint() async {
    _userData.hints++;
    _scheduleSave();
  }

  Future<void> useHint() async {
    if (_userData.hints > 0) {
      _userData.hints--;
      _scheduleSave();
    }
  }

  /// Claim daily reward. Returns the reward details.
  Future<Map<String, dynamic>> claimDailyReward() async {
    final reward = _userData.claimDailyReward();
    _scheduleSave();
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
    _scheduleSave();
  }

  Future<void> resetProgress() async {
    _userData = UserData();
    await saveUserData(); // Immediate write for destructive action
  }

  /// Cancel pending timers when the service is no longer needed.
  void dispose() {
    _writeTimer?.cancel();
  }

  static void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[StorageService] $message');
    }
  }
}
