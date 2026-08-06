// ArrowSlide 3D — Production Level Generator (1–200)
// Run with: dart run tools/generate_levels.dart
//
// Neuroscience-based engagement curve:
//   - Levels 1-5:   Tutorial (3x3/4x4, 2-4 arrows, very generous timer)
//   - Levels 6-15:  Easy onboarding (4x4/5x5, 4-8 arrows, gentle ramp)
//   - Levels 16-50: Easy (5x5/6x6, 8-18 arrows, medium timer)
//   - Levels 51-100: Medium (6x6/7x7, 16-30 arrows, tighter timer)
//   - Levels 101-150: Hard (7x7/8x8, 25-50 arrows, challenging timer)
//   - Levels 151-200: Expert (8x8/9x9/10x10, 40-80 arrows, tight timer)
//
// Addiction psychology principles applied:
//   1. Variable reward schedule — star thresholds vary, keeping surprise
//   2. Flow state maintenance — difficulty ramps smoothly, no sudden spikes
//   3. Near-miss effect — tight par moves create "almost got 3 stars" feeling
//   4. Mastery gradient — each level is slightly harder, building competence
//   5. Breather levels — every 10th level is slightly easier (dopamine reset)
//   6. Chapter transitions — first level of each chapter is a confidence booster
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
  stdout.writeln('✓ Generated 200 ArrowSlide 3D levels with neuroscience-based difficulty!');
}

void _generateLevel(int id) {
  // ─── Grid Size Progression ────────────────────────────────────
  int size;
  if (id <= 3) {
    size = 3;          // Tutorial: tiny grid
  } else if (id <= 10) {
    size = 4;          // Early easy: small grid
  } else if (id <= 25) {
    size = 5;          // Easy: medium grid
  } else if (id <= 50) {
    size = 6;          // Easy-medium transition
  } else if (id <= 80) {
    size = 7;          // Medium: large grid
  } else if (id <= 120) {
    size = 8;          // Hard: bigger grid
  } else if (id <= 170) {
    size = 9;          // Expert: very large
  } else {
    size = 10;         // Master: maximum grid
  }

  // ─── Block Count Progression (Neuroscience: gradual ramp) ─────
  int targetBlocks;
  int minDepth;

  if (id <= 3) {
    // Tutorial: just 2-3 arrows, instant success feeling
    targetBlocks = 1 + id;
    minDepth = 1;
  } else if (id <= 10) {
    // Early easy: 4-7 arrows
    final t = (id - 4) / 6.0;
    targetBlocks = (4 + t * 3).round();
    minDepth = 1;
  } else if (id <= 25) {
    // Easy: 7-14 arrows
    final t = (id - 11) / 14.0;
    targetBlocks = (7 + t * 7).round();
    minDepth = (1 + t * 2).round();
  } else if (id <= 50) {
    // Easy-Medium: 14-22 arrows
    final t = (id - 26) / 24.0;
    targetBlocks = (14 + t * 8).round();
    minDepth = (3 + t * 3).round();
  } else if (id <= 80) {
    // Medium: 20-35 arrows
    final t = (id - 51) / 29.0;
    targetBlocks = (20 + t * 15).round();
    minDepth = (5 + t * 5).round();
  } else if (id <= 120) {
    // Hard: 30-50 arrows
    final t = (id - 81) / 39.0;
    targetBlocks = (30 + t * 20).round();
    minDepth = (8 + t * 7).round();
  } else if (id <= 170) {
    // Expert: 45-70 arrows
    final t = (id - 121) / 49.0;
    targetBlocks = (45 + t * 25).round();
    minDepth = (12 + t * 8).round();
  } else {
    // Master: 60-80 arrows
    final t = (id - 171) / 29.0;
    targetBlocks = (60 + t * 20).round();
    minDepth = (18 + t * 7).round();
  }

  // ─── Breather Levels (Dopamine Reset) ─────────────────────────
  // Every 10th level is slightly easier (fewer blocks, more time)
  final isBreatherLevel = id > 5 && id % 10 == 0;
  // First level of each chapter (51, 101, 151) is a confidence booster
  final isChapterStart = id == 51 || id == 101 || id == 151;

  if (isBreatherLevel) {
    targetBlocks = (targetBlocks * 0.75).round().clamp(3, 80);
    minDepth = (minDepth * 0.7).round().clamp(1, 20);
  }
  if (isChapterStart) {
    targetBlocks = (targetBlocks * 0.65).round().clamp(3, 80);
    minDepth = (minDepth * 0.5).round().clamp(1, 15);
  }

  // Clamp target blocks to grid capacity (max ~85% fill)
  final maxCapacity = (size * size * 0.85).round();
  targetBlocks = targetBlocks.clamp(2, maxCapacity);

  // ─── Difficulty Label ─────────────────────────────────────────
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

  // ─── Timer Progression (generous → tight) ─────────────────────
  // Base timer scales with block count and difficulty
  // Formula: blocks * secondsPerBlock + buffer
  int timeLimitSeconds;
  int threeStarSec;
  int twoStarSec;

  if (id <= 5) {
    // Tutorial: very generous (60s for 2-4 blocks)
    timeLimitSeconds = 60;
    threeStarSec = 15;
    twoStarSec = 30;
  } else if (id <= 25) {
    // Easy: comfortable
    final secsPerBlock = 8.0 - ((id - 6) / 19.0) * 2.0; // 8s → 6s per block
    timeLimitSeconds = (targetBlocks * secsPerBlock + 20).round().clamp(45, 120);
    threeStarSec = (timeLimitSeconds * 0.3).round();
    twoStarSec = (timeLimitSeconds * 0.6).round();
  } else if (id <= 50) {
    // Easy-Medium: moderate
    final secsPerBlock = 6.0 - ((id - 26) / 24.0) * 1.5; // 6s → 4.5s per block
    timeLimitSeconds = (targetBlocks * secsPerBlock + 15).round().clamp(60, 150);
    threeStarSec = (timeLimitSeconds * 0.28).round();
    twoStarSec = (timeLimitSeconds * 0.55).round();
  } else if (id <= 100) {
    // Medium: tighter
    final secsPerBlock = 5.0 - ((id - 51) / 49.0) * 1.0; // 5s → 4s per block
    timeLimitSeconds = (targetBlocks * secsPerBlock + 15).round().clamp(90, 200);
    threeStarSec = (timeLimitSeconds * 0.25).round();
    twoStarSec = (timeLimitSeconds * 0.5).round();
  } else if (id <= 150) {
    // Hard: challenging
    final secsPerBlock = 4.0 - ((id - 101) / 49.0) * 0.8; // 4s → 3.2s per block
    timeLimitSeconds = (targetBlocks * secsPerBlock + 20).round().clamp(120, 280);
    threeStarSec = (timeLimitSeconds * 0.22).round();
    twoStarSec = (timeLimitSeconds * 0.45).round();
  } else {
    // Expert: tight but fair
    final secsPerBlock = 3.5 - ((id - 151) / 49.0) * 0.7; // 3.5s → 2.8s per block
    timeLimitSeconds = (targetBlocks * secsPerBlock + 25).round().clamp(150, 360);
    threeStarSec = (timeLimitSeconds * 0.2).round();
    twoStarSec = (timeLimitSeconds * 0.42).round();
  }

  // Breather levels get +40% time
  if (isBreatherLevel || isChapterStart) {
    timeLimitSeconds = (timeLimitSeconds * 1.4).round();
    threeStarSec = (threeStarSec * 1.3).round();
    twoStarSec = (twoStarSec * 1.3).round();
  }

  // ─── Generate the DAG-based puzzle ────────────────────────────
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

  // Log key levels for verification
  if (id <= 5 || id % 25 == 0 || id == 51 || id == 101 || id == 151) {
    stdout.writeln(
      'Level $id: ${size}x$size, ${blocks.length} blocks, '
      'timer=${timeLimitSeconds}s, difficulty=$difficulty'
      '${isBreatherLevel ? " [BREATHER]" : ""}'
      '${isChapterStart ? " [CHAPTER START]" : ""}',
    );
  }
}

/// Builds a guaranteed-solvable DAG-based level.
/// Uses reverse construction: place arrows that block others, building a topological chain.
List<Map<String, dynamic>> _buildDAGLevel(
  int w,
  int h,
  int targetBlocks,
  int minDepth,
  Random rng,
) {
  final dirs = ['up', 'down', 'left', 'right'];
  final placed = <Map<String, dynamic>>[];
  final occupiedCells = <String>{};
  int blockIdx = 1;

  (int, int) delta(String d) => switch (d) {
    'up' => (0, -1),
    'down' => (0, 1),
    'left' => (-1, 0),
    _ => (1, 0),
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
      final cell = randomEmpty(50);
      if (cell == null) break;
      final dir = dirs[rng.nextInt(4)];
      final b = {
        'id': 'a_$blockIdx',
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

  // --- PHASE 2: Fill remaining slots with free arrows (if needed) ---
  int fillAttempts = 0;
  while (placed.length < targetBlocks && fillAttempts < 500) {
    fillAttempts++;
    final cell = randomEmpty(50);
    if (cell == null) break;
    final dir = dirs[rng.nextInt(4)];
    final b = {
      'id': 'a_$blockIdx',
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

bool _isSolvable(int w, int h, List<Map<String, dynamic>> initialBlocks) {
  final current = initialBlocks
      .map((b) => Map<String, dynamic>.from(b))
      .toList();
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

bool _canExit(
  int w,
  int h,
  Map<String, dynamic> b,
  List<Map<String, dynamic>> all,
) {
  (int, int) delta(String d) => switch (d) {
    'up' => (0, -1),
    'down' => (0, 1),
    'left' => (-1, 0),
    _ => (1, 0),
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
