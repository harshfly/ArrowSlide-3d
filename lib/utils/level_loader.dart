import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/level.dart';
import 'daily_challenge_service.dart';

/// Loads level JSON files from the assets folder with caching.
///
/// Production optimizations:
/// - LRU-style cache for loaded levels
/// - Level list metadata computed once and cached
/// - Error handling with debug-only logging
class LevelLoader {
  static final Map<int, Level> _cache = {};
  static List<Map<String, dynamic>>? _levelListCache;

  /// Load a single level by ID.
  static Future<Level> loadLevel(int levelId) async {
    if (levelId == 999) {
      return DailyChallengeService.getDailyLevel();
    }

    final cached = _cache[levelId];
    if (cached != null) return cached;

    try {
      final paddedId = levelId.toString().padLeft(3, '0');
      final jsonStr = await rootBundle.loadString(
        'assets/levels/level_$paddedId.json',
      );
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final level = Level.fromJson(json);
      _cache[levelId] = level;
      return level;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LevelLoader] Failed to load level $levelId: $e');
      }
      rethrow;
    }
  }

  /// Load level metadata (id, difficulty) for all available levels.
  /// Results are cached after first load.
  static Future<List<Map<String, dynamic>>> loadLevelList() async {
    if (_levelListCache != null) return _levelListCache!;

    final List<Map<String, dynamic>> levelMetas = [];

    for (int i = 1; i <= 100; i++) {
      try {
        final paddedId = i.toString().padLeft(3, '0');
        final jsonStr = await rootBundle.loadString(
          'assets/levels/level_$paddedId.json',
        );
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        levelMetas.add({
          'id': json['id'],
          'difficulty': json['difficulty'],
          'gridWidth': json['gridWidth'],
          'gridHeight': json['gridHeight'],
          'parMoves': json['parMoves'],
        });
      } catch (_) {
        // Level file doesn't exist yet — stop scanning
        break;
      }
    }

    _levelListCache = levelMetas;
    return levelMetas;
  }

  /// Clear all caches.
  static void clearCache() {
    _cache.clear();
    _levelListCache = null;
  }
}
