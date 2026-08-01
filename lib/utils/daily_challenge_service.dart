import 'dart:math';
import '../models/level.dart';
import '../models/arrow_block.dart';

/// Provides a dynamically generated, deterministic Daily Challenge level on a daily basis.
/// Every day at midnight, a brand new unique puzzle layout is automatically generated.
class DailyChallengeService {
  DailyChallengeService._();

  /// Computes a unique integer seed for today's calendar date (e.g., 20260801 for Aug 1, 2026).
  static int getTodaySeed() {
    final now = DateTime.now();
    return (now.year * 10000) + (now.month * 100) + now.day;
  }

  /// Returns a nicely formatted string for today's challenge date (e.g., "AUGUST 1, 2026").
  static String getFormattedTodayDate() {
    final now = DateTime.now();
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    final monthStr = months[now.month - 1];
    return '$monthStr ${now.day}, ${now.year}';
  }

  /// Calculates the time remaining until midnight (next daily challenge).
  static String getTimeUntilNextChallenge() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Generates today's unique Daily Challenge level (7x7 Hardcore Grid).
  static Level getDailyLevel() {
    final seed = getTodaySeed();
    final rng = Random(seed);

    const int size = 7;
    const int targetBlocks = 32;
    const int minDepth = 12;

    final blockMaps = _buildDAGLevel(size, size, targetBlocks, minDepth, rng);

    final blocks = blockMaps.map((b) {
      return ArrowBlock(
        id: b['id'] as String,
        x: b['x'] as int,
        y: b['y'] as int,
        width: 1,
        height: 1,
        direction: Direction.fromString(b['direction'] as String),
      );
    }).toList();

    return Level(
      id: 999,
      gridWidth: size,
      gridHeight: size,
      parMoves: blocks.length + 3,
      threeStarSec: 35,
      twoStarSec: 70,
      timeLimitSeconds: 120,
      difficulty: 'hardcore',
      tiles: [],
      blocks: blocks,
      powerUps: [],
    );
  }

  // ─── Reverse-DAG Procedural Generator ──────────────────────────────────
  static List<Map<String, dynamic>> _buildDAGLevel(
      int w, int h, int targetBlocks, int minDepth, Random rng) {
    final dirs = ['up', 'down', 'left', 'right'];
    final placed = <Map<String, dynamic>>[];
    final occupiedCells = <String>{};
    int blockIdx = 1;

    (int, int) delta(String d) => switch (d) {
      'up' => (0, -1),
      'down' => (0, 1),
      'left' => (-1, 0),
      _ => (1, 0)
    };

    bool inBounds(int x, int y) => x >= 0 && x < w && y >= 0 && y < h;

    ({int x, int y})? randomEmpty(int maxTries) {
      for (int i = 0; i < maxTries; i++) {
        final x = rng.nextInt(w);
        final y = rng.nextInt(h);
        if (!occupiedCells.contains('$x,$y')) return (x: x, y: y);
      }
      return null;
    }

    bool canExit(Map<String, dynamic> b, List<Map<String, dynamic>> others) {
      final dir = b['direction'] as String;
      final (dx, dy) = delta(dir);
      int cx = (b['x'] as int) + dx;
      int cy = (b['y'] as int) + dy;
      while (inBounds(cx, cy)) {
        for (final o in others) {
          if (o['id'] != b['id'] && o['x'] == cx && o['y'] == cy) return false;
        }
        cx += dx;
        cy += dy;
      }
      return true;
    }

    Map<String, dynamic>? placeBlocker(Map<String, dynamic> target) {
      final dir = target['direction'] as String;
      final (dx, dy) = delta(dir);
      int cx = (target['x'] as int) + dx;
      int cy = (target['y'] as int) + dy;

      final pathCells = <({int x, int y})>[];
      while (inBounds(cx, cy)) {
        if (!occupiedCells.contains('$cx,$cy')) {
          pathCells.add((x: cx, y: cy));
        }
        cx += dx;
        cy += dy;
      }

      if (pathCells.isEmpty) return null;

      final pick = pathCells[rng.nextInt(pathCells.length)];
      final shuffled = List<String>.from(dirs)..shuffle(rng);
      for (final d in shuffled) {
        final (bx, by) = delta(d);
        final nx = pick.x + bx;
        final ny = pick.y + by;
        if (!inBounds(nx, ny) || !occupiedCells.contains('$nx,$ny')) {
          return {
            'id': 'c_$blockIdx',
            'x': pick.x,
            'y': pick.y,
            'width': 1,
            'height': 1,
            'direction': d,
          };
        }
      }
      return null;
    }

    int chainAttempts = 0;
    while (placed.length < targetBlocks && chainAttempts < 2000) {
      chainAttempts++;

      if (placed.isEmpty) {
        final cell = randomEmpty(50);
        if (cell == null) break;
        final dir = dirs[rng.nextInt(4)];
        final b = {
          'id': 'c_$blockIdx',
          'x': cell.x,
          'y': cell.y,
          'width': 1,
          'height': 1,
          'direction': dir,
        };
        if (canExit(b, placed)) {
          placed.add(b);
          occupiedCells.add('${cell.x},${cell.y}');
          blockIdx++;
        }
        continue;
      }

      final target = placed[rng.nextInt(placed.length)];
      final blocker = placeBlocker(target);
      if (blocker == null) continue;

      final bKey = '${blocker['x']},${blocker['y']}';
      if (occupiedCells.contains(bKey)) continue;

      placed.add(blocker);
      occupiedCells.add(bKey);
      blockIdx++;

      if (!_isSolvable(w, h, placed)) {
        placed.removeLast();
        occupiedCells.remove(bKey);
        blockIdx--;
      }
    }

    int fillAttempts = 0;
    while (placed.length < targetBlocks && fillAttempts < 500) {
      fillAttempts++;
      final cell = randomEmpty(50);
      if (cell == null) break;
      final dir = dirs[rng.nextInt(4)];
      final b = {
        'id': 'c_$blockIdx',
        'x': cell.x,
        'y': cell.y,
        'width': 1,
        'height': 1,
        'direction': dir,
      };
      placed.add(b);
      occupiedCells.add('${cell.x},${cell.y}');
      if (!_isSolvable(w, h, placed)) {
        placed.removeLast();
        occupiedCells.remove('${cell.x},${cell.y}');
      } else {
        blockIdx++;
      }
    }

    return placed;
  }

  static bool _isSolvable(int w, int h, List<Map<String, dynamic>> initialBlocks) {
    final current = initialBlocks.map((b) => Map<String, dynamic>.from(b)).toList();
    while (current.isNotEmpty) {
      int found = -1;
      for (int i = 0; i < current.length; i++) {
        if (_canExit(w, h, current[i], current)) {
          found = i;
          break;
        }
      }
      if (found == -1) return false;
      current.removeAt(found);
    }
    return true;
  }

  static bool _canExit(int w, int h, Map<String, dynamic> b, List<Map<String, dynamic>> all) {
    (int, int) delta(String d) => switch (d) {
      'up' => (0, -1),
      'down' => (0, 1),
      'left' => (-1, 0),
      _ => (1, 0)
    };
    final (dx, dy) = delta(b['direction'] as String);
    int cx = (b['x'] as int) + dx;
    int cy = (b['y'] as int) + dy;
    while (cx >= 0 && cx < w && cy >= 0 && cy < h) {
      for (final o in all) {
        if (o['id'] != b['id'] && o['x'] == cx && o['y'] == cy) return false;
      }
      cx += dx;
      cy += dy;
    }
    return true;
  }
}
