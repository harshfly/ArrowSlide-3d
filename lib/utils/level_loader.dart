import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/level.dart';

/// Loads level JSON files from the assets folder.
class LevelLoader {
  static final Map<int, Level> _cache = {};

  /// Load a single level by ID.
  static Future<Level> loadLevel(int levelId) async {
    if (_cache.containsKey(levelId)) {
      return _cache[levelId]!;
    }

    final paddedId = levelId.toString().padLeft(3, '0');
    final jsonStr = await rootBundle.loadString('assets/levels/level_$paddedId.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final level = Level.fromJson(json);
    _cache[levelId] = level;
    return level;
  }

  /// Load level metadata (id, difficulty) for all available levels.
  /// Used by the level select screen.
  static Future<List<Map<String, dynamic>>> loadLevelList() async {
    final List<Map<String, dynamic>> levelMetas = [];

    for (int i = 1; i <= 100; i++) {
      try {
        final paddedId = i.toString().padLeft(3, '0');
        final jsonStr = await rootBundle.loadString('assets/levels/level_$paddedId.json');
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

    return levelMetas;
  }

  /// Clear the level cache.
  static void clearCache() => _cache.clear();
}
