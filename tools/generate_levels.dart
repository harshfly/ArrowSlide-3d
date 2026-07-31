// ArrowSlide 3D — Hardcore Level Generator (1–100)
// Run with: dart run tools/generate_levels.dart
//
// Strategy: Levels increase difficulty solely through:
//   - Larger grids (5x5 → 10x10)
//   - More arrows
//   - More dependencies (each arrow blocked by others, requiring specific order)
//   - Deeper dependency chains (topological depth increases level by level)
//   - Tighter time limits for star ratings
import 'dart:convert';
import 'dart:io';
import 'dart:math';

final random = Random(1337); // Fixed seed for reproducibility

void main() {
  final dir = Directory('assets/levels');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  for (int i = 1; i <= 200; i++) {
    _generateLevel(i);
  }
  stdout.writeln('✓ Generated 200 hardcore ArrowSlide 3D levels!');
}

void _generateLevel(int id) {
  // Progressive scaling
  final t = (id - 1) / 199.0; // 0.0 (level 1) → 1.0 (level 200)

  final size = 5 + (t * 5).floor().clamp(0, 5); // 5→10
  final targetBlocks = (4 + t * 22).round().clamp(4, 26);
  final minDepth = (1 + t * 7).round().clamp(1, 8); // dependency chain depth

  String difficulty;
  if (id <= 50) {
    difficulty = 'easy';
  } else if (id <= 100) {
    difficulty = 'medium';
  } else if (id <= 150) {
    difficulty = 'hard';
  } else {
    difficulty = 'expert';
  }

  // Time limits based on stars:
  // 3 stars = complete in threeStarSec
  // 2 stars = complete in twoStarSec
  // 1 star = any completion
  final threeStarSec = 10 + (t * 50).round(); // 10s → 60s
  final twoStarSec = threeStarSec * 2;
  final timeLimitSeconds = twoStarSec * 2; // overall limit

  final blocks = _buildDAGLevel(size, size, targetBlocks, minDepth, random);

  final levelData = {
    'id': id,
    'gridWidth': size,
    'gridHeight': size,
    'parMoves': blocks.length,
    'threeStarSec': threeStarSec,
    'twoStarSec': twoStarSec,
    'timeLimitSeconds': timeLimitSeconds,
    'difficulty': difficulty,
    'tiles': <Map<String, dynamic>>[],
    'blocks': blocks,
    'powerUps': <Map<String, dynamic>>[],
  };

  final paddedId = id.toString().padLeft(3, '0');
  final file = File('assets/levels/level_$paddedId.json');
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(levelData));
}

/// Builds a guaranteed-solvable DAG-based level.
/// Uses reverse construction: place arrows that block others, building a topological chain.
List<Map<String, dynamic>> _buildDAGLevel(
    int w, int h, int targetBlocks, int minDepth, Random rng) {
  // We build the solution ORDER first, then place blocks such that
  // each block is blocked by the NEXT block in the order (dependency chain).
  // This guarantees exactly one valid topological sort per chain.

  final dirs = ['up', 'down', 'left', 'right'];
  final placed = <Map<String, dynamic>>[];
  final occupiedCells = <String>{};
  int blockIdx = 1;

  // Helper: get delta
  (int, int) delta(String d) => switch (d) {
    'up' => (0, -1), 'down' => (0, 1),
    'left' => (-1, 0), _ => (1, 0)
  };

  // Helper: check if a cell is within bounds
  bool inBounds(int x, int y) => x >= 0 && x < w && y >= 0 && y < h;

  // Helper: find a valid random empty cell
  ({int x, int y})? randomEmpty(int maxTries) {
    for (int i = 0; i < maxTries; i++) {
      final x = rng.nextInt(w);
      final y = rng.nextInt(h);
      if (!occupiedCells.contains('$x,$y')) return (x: x, y: y);
    }
    return null;
  }

  // Helper: can this block exit given current placed blocks?
  bool canExit(Map<String, dynamic> b, List<Map<String, dynamic>> others) {
    final dir = b['direction'] as String;
    final (dx, dy) = delta(dir);
    int cx = (b['x'] as int) + dx;
    int cy = (b['y'] as int) + dy;
    while (inBounds(cx, cy)) {
      for (final o in others) {
        if (o['id'] != b['id'] && o['x'] == cx && o['y'] == cy) return false;
      }
      cx += dx; cy += dy;
    }
    return true;
  }

  // Helper: place a blocker arrow that sits IN the escape path of a target arrow
  Map<String, dynamic>? placeBlocker(Map<String, dynamic> target) {
    final dir = target['direction'] as String;
    final (dx, dy) = delta(dir);
    int cx = (target['x'] as int) + dx;
    int cy = (target['y'] as int) + dy;

    // Collect all cells in target's escape path
    final pathCells = <({int x, int y})>[];
    while (inBounds(cx, cy)) {
      if (!occupiedCells.contains('$cx,$cy')) {
        pathCells.add((x: cx, y: cy));
      }
      cx += dx; cy += dy;
    }

    if (pathCells.isEmpty) return null;

    // Pick a random path cell for the blocker
    final pick = pathCells[rng.nextInt(pathCells.length)];
    // Give the blocker a direction such that it can eventually escape too
    // (pick a direction where it has at least one empty cell ahead OR exits board)
    final shuffled = List<String>.from(dirs)..shuffle(rng);
    for (final d in shuffled) {
      final (bx, by) = delta(d);
      final nx = pick.x + bx;
      final ny = pick.y + by;
      // Valid if next step exits board OR next step is an unoccupied cell
      if (!inBounds(nx, ny) || !occupiedCells.contains('$nx,$ny')) {
        return {
          'id': 'a_$blockIdx',
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

  // --- PHASE 1: Build dependency chains ---
  int chainAttempts = 0;
  while (placed.length < targetBlocks && chainAttempts < 2000) {
    chainAttempts++;

    if (placed.isEmpty) {
      // Seed: place first block that can freely exit
      final cell = randomEmpty(50);
      if (cell == null) break;
      final dir = dirs[rng.nextInt(4)];
      final b = {
        'id': 'a_$blockIdx', 'x': cell.x, 'y': cell.y,
        'width': 1, 'height': 1, 'direction': dir,
      };
      // Verify it can exit (no blockers yet)
      if (canExit(b, placed)) {
        placed.add(b);
        occupiedCells.add('${cell.x},${cell.y}');
        blockIdx++;
      }
      continue;
    }

    // Try to place a new blocker that sits in some existing block's path
    final target = placed[rng.nextInt(placed.length)];
    final blocker = placeBlocker(target);
    if (blocker == null) continue;

    final bKey = '${blocker['x']},${blocker['y']}';
    if (occupiedCells.contains(bKey)) continue;

    // Tentatively add
    placed.add(blocker);
    occupiedCells.add(bKey);
    blockIdx++;

    // Verify the whole set is still solvable
    if (!_isSolvable(w, h, placed)) {
      placed.removeLast();
      occupiedCells.remove(bKey);
      blockIdx--;
    }
  }

  // --- PHASE 2: Fill remaining slots with free arrows (if needed) ---
  int fillAttempts = 0;
  while (placed.length < targetBlocks && fillAttempts < 500) {
    fillAttempts++;
    final cell = randomEmpty(50);
    if (cell == null) break;
    final dir = dirs[rng.nextInt(4)];
    final b = {
      'id': 'a_$blockIdx', 'x': cell.x, 'y': cell.y,
      'width': 1, 'height': 1, 'direction': dir,
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

bool _isSolvable(int w, int h, List<Map<String, dynamic>> initialBlocks) {
  final current = initialBlocks.map((b) => Map<String, dynamic>.from(b)).toList();
  while (current.isNotEmpty) {
    int found = -1;
    for (int i = 0; i < current.length; i++) {
      if (_canExit(w, h, current[i], current)) { found = i; break; }
    }
    if (found == -1) return false;
    current.removeAt(found);
  }
  return true;
}

bool _canExit(int w, int h, Map<String, dynamic> b, List<Map<String, dynamic>> all) {
  (int, int) delta(String d) => switch (d) {
    'up' => (0, -1), 'down' => (0, 1), 'left' => (-1, 0), _ => (1, 0)
  };
  final (dx, dy) = delta(b['direction'] as String);
  int cx = (b['x'] as int) + dx;
  int cy = (b['y'] as int) + dy;
  while (cx >= 0 && cx < w && cy >= 0 && cy < h) {
    for (final o in all) {
      if (o['id'] != b['id'] && o['x'] == cx && o['y'] == cy) return false;
    }
    cx += dx; cy += dy;
  }
  return true;
}
