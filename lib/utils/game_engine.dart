import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config.dart';
import '../models/level.dart';
import '../models/arrow_block.dart';

/// Pure ArrowSlide 3D Engine — time-based star rating, cell-by-cell sliding.
///
/// Production optimizations:
/// - Guard against post-dispose Future.delayed callbacks
/// - Precomputed block lookup map for O(1) getBlockAt
/// - Prevents double win/fail detection
/// - Cancels all timers on dispose
class GameEngine extends ChangeNotifier {
  late Level _level;
  late List<ArrowBlock> _blocks;

  int _moveCount = 0;
  int _score = 0;
  int _timeRemaining = 0;
  int _lives = 3;
  bool _isWon = false;
  bool _isFailed = false;
  bool _isPaused = false;
  bool _invalidTapTriggered = false;
  bool _disposed = false;
  Timer? _elapsedTimer;
  Timer? _invalidTapResetTimer;

  final List<_UndoState> _undoStack = [];

  // Block position lookup map for O(1) access
  final Map<String, ArrowBlock> _blockPositionMap = {};

  // ─── Getters ───────────────────────────────────────────────────
  Level get level => _level;
  List<ArrowBlock> get blocks => List.unmodifiable(_blocks);
  int get moveCount => _moveCount;
  int get score => _score;
  int get timeRemaining => _timeRemaining;
  int get elapsedSeconds => _timeRemaining;
  int get lives => _lives;
  bool get isWon => _isWon;
  bool get isFailed => _isFailed;
  bool get isPaused => _isPaused;
  bool get invalidTapTriggered => _invalidTapTriggered;
  int get parMoves => _level.parMoves;
  int get gridWidth => _level.gridWidth;
  int get gridHeight => _level.gridHeight;
  bool get canUndo => _undoStack.isNotEmpty;

  /// Star rating based on REMAINING LIVES.
  int get starRating => _lives.clamp(0, 3);

  String get elapsedFormatted {
    final m = (_timeRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_timeRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─── Initialization ────────────────────────────────────────────
  void loadLevel(Level level) {
    _level = level;
    _blocks = level.blocks.map((b) => b.copyWith()).toList();
    _rebuildPositionMap();
    _moveCount = 0;
    _score = 0;

    int baseTime = 60;
    switch (level.difficulty) {
      case 'Easy':
        baseTime = 45;
      case 'Medium':
        baseTime = 90;
      case 'Hard':
        baseTime = 120;
      case 'Expert':
        baseTime = 180;
    }
    _timeRemaining = baseTime;

    _lives = 3;
    _isWon = false;
    _isFailed = false;
    _isPaused = false;
    _invalidTapTriggered = false;
    _undoStack.clear();
    _startTimer();
    _checkGameState();
    _safeNotify();
  }

  void _rebuildPositionMap() {
    _blockPositionMap.clear();
    for (final b in _blocks) {
      _blockPositionMap['${b.x},${b.y}'] = b;
    }
  }

  void _startTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      if (!_isPaused && !_isWon && !_isFailed) {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          _isFailed = true;
          _elapsedTimer?.cancel();
        }
        _safeNotify();
      }
    });
  }

  ArrowBlock? getBlockAt(int x, int y) {
    return _blockPositionMap['$x,$y'];
  }

  void pause() {
    _isPaused = true;
    _safeNotify();
  }

  void resume() {
    _isPaused = false;
    _safeNotify();
  }

  // ─── Core Cell-by-Cell Movement Logic ─────────────────────────

  /// Calculate slide: returns (finalX, finalY, escaped, moved).
  (int, int, bool, bool) _calculateSlide(ArrowBlock block) {
    final (dx, dy) = block.direction.delta;
    int cx = block.x;
    int cy = block.y;

    while (true) {
      cx += dx;
      cy += dy;
      if (cx < 0 || cx >= _level.gridWidth || cy < 0 || cy >= _level.gridHeight) {
        // Path is completely clear — set target outside the board for animation.
        int farX = block.x;
        int farY = block.y;
        if (dx < 0) farX = -3;
        if (dx > 0) farX = _level.gridWidth + 2;
        if (dy < 0) farY = -3;
        if (dy > 0) farY = _level.gridHeight + 2;
        return (farX, farY, true, true);
      }
      if (getBlockAt(cx, cy) != null) {
        return (block.x, block.y, false, false);
      }
    }
  }

  bool canBlockMove(ArrowBlock block) {
    final (_, _, _, moved) = _calculateSlide(block);
    return moved;
  }

  bool canAnyBlockMove() {
    for (final b in _blocks) {
      if (canBlockMove(b)) return true;
    }
    return false;
  }

  void _checkGameState() {
    if (_blocks.isEmpty) {
      _isWon = true;
      _isFailed = false;
      _elapsedTimer?.cancel();
    } else if (!canAnyBlockMove()) {
      _isFailed = true;
    } else {
      _isFailed = false;
    }
  }

  /// Taps a block — returns true if block moved/escaped.
  bool moveBlock(String blockId) {
    if (_isWon || _isFailed || _isPaused) return false;
    final blockIndex = _blocks.indexWhere((b) => b.id == blockId);
    if (blockIndex == -1) return false;

    final block = _blocks[blockIndex];
    _invalidTapTriggered = false;

    final (finalX, finalY, escaped, moved) = _calculateSlide(block);

    if (!moved) {
      _invalidTapTriggered = true;
      _lives--;

      if (_lives <= 0) {
        _isFailed = true;
        _elapsedTimer?.cancel();
      }

      _safeNotify();
      // Reset invalid tap flag after brief delay — guarded against dispose
      _invalidTapResetTimer?.cancel();
      _invalidTapResetTimer = Timer(const Duration(milliseconds: 200), () {
        if (!_disposed) {
          _invalidTapTriggered = false;
          _safeNotify();
        }
      });
      return false;
    }

    _pushUndo();
    _moveCount++;

    if (escaped) {
      _blocks[blockIndex] = block.copyWith(x: finalX, y: finalY);
      _rebuildPositionMap();
      _score += 100;
      // Delay actual removal so the UI can animate the slide-out — guarded
      Timer(GameConfig.blockSlideDuration, () {
        if (!_disposed) {
          _blocks.removeWhere((b) => b.id == block.id);
          _rebuildPositionMap();
          _checkGameState();
          _safeNotify();
        }
      });
    } else {
      _blocks[blockIndex] = block.copyWith(x: finalX, y: finalY);
      _rebuildPositionMap();
      _score += 10;
    }

    _checkGameState();
    _safeNotify();
    return true;
  }

  void addLife() {
    _lives++;
    _isFailed = false;
    _startTimer();
    _safeNotify();
  }

  /// Hint solver — returns the ID of a block that can currently escape.
  String? getHintBlockId() {
    // 1. Check for a block that can directly escape
    for (final b in _blocks) {
      final (_, _, escaped, _) = _calculateSlide(b);
      if (escaped) return b.id;
    }
    // 2. Fallback: check for any block that can move
    for (final b in _blocks) {
      final (_, _, _, moved) = _calculateSlide(b);
      if (moved) return b.id;
    }
    return _blocks.isNotEmpty ? _blocks.first.id : null;
  }

  // ─── Undo & Restart ───────────────────────────────────────────

  void _pushUndo() {
    _undoStack.add(_UndoState(
      blocks: _blocks.map((b) => b.copyWith()).toList(),
      score: _score,
      timeRemaining: _timeRemaining,
    ));
    if (_undoStack.length > GameConfig.maxUndos) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final state = _undoStack.removeLast();
    _blocks = state.blocks;
    _rebuildPositionMap();
    _score = state.score;
    _timeRemaining = state.timeRemaining;
    _moveCount = (_moveCount - 1).clamp(0, _moveCount);
    _isWon = false;
    _checkGameState();
    _safeNotify();
  }

  void restart() {
    loadLevel(_level);
  }

  /// Safe notifyListeners that checks disposal state.
  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _elapsedTimer?.cancel();
    _invalidTapResetTimer?.cancel();
    _elapsedTimer = null;
    _invalidTapResetTimer = null;
    super.dispose();
  }
}

class _UndoState {
  final List<ArrowBlock> blocks;
  final int score;
  final int timeRemaining;

  const _UndoState({
    required this.blocks,
    required this.score,
    required this.timeRemaining,
  });
}
