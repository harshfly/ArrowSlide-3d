import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/game_engine.dart';
import '../utils/level_loader.dart';
import '../utils/storage_service.dart';
import '../utils/ad_service.dart';
import '../utils/audio_service.dart';
import '../models/arrow_block.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/arrow_block_widget.dart';
import '../widgets/dotted_background.dart';

/// Gameplay Screen — Dark space theme, time-based stars, glossy cubes, banner ads.
///
/// Production optimizations:
/// - Separate [ListenableBuilder] for timer to avoid full-tree rebuilds
/// - Cached [MediaQuery] values
/// - Guard against double-win detection
/// - Dispose-safe engine listener
class GameplayScreen extends StatefulWidget {
  final int levelId;
  const GameplayScreen({super.key, required this.levelId});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with TickerProviderStateMixin {
  late final GameEngine _engine;
  bool _isLoading = true;
  String? _error;
  String? _highlightedBlockId;
  int _retryCount = 0;
  bool _winHandled = false;
  bool _isShowingGameOver = false;
  bool _isProcessingTap = false;

  // Cached layout values
  late double _screenWidth;
  late double _screenHeight;

  // Shake animation
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _engine.addListener(_onEngineStateChanged);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(_shakeController);
    _loadLevelData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.of(context);
    _screenWidth = mq.size.width;
    _screenHeight = mq.size.height;
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineStateChanged);
    _engine.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadLevelData() async {
    try {
      final level = await LevelLoader.loadLevel(widget.levelId);
      if (!mounted) return;
      _engine.loadLevel(level);
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load level ${widget.levelId}';
      });
    }
  }

  void _onEngineStateChanged() {
    if (!mounted) return;
    if (_engine.invalidTapTriggered) {
      final storage = Provider.of<StorageService>(context, listen: false);
      if (storage.userData.settings.vibrationEnabled) {
        HapticFeedback.vibrate();
      }
      AudioService.instance.playFailSound();
      _shakeController.forward(from: 0);
    }
    if (_engine.isWon && !_winHandled) {
      _winHandled = true;
      AudioService.instance.playWinSound();
      _onLevelWon();
    } else if (_engine.isFailed) {
      _onLevelFailed();
    }
  }

  Future<void> _onLevelWon() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    await storage.completeLevel(
        widget.levelId, _engine.moveCount, _engine.starRating);
    if (!mounted) return;

    // Show interstitial every N levels
    if (widget.levelId % GameConfig.interstitialFrequency == 0) {
      await AdService.instance.showInterstitialAd();
    }
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRouter.victory, arguments: {
      'levelId': widget.levelId,
      'moves': _engine.moveCount,
      'stars': _engine.starRating,
      'bestMoves': _engine.moveCount,
      'elapsedSec': _engine.elapsedSeconds,
    });
  }

  void _onLevelFailed() {
    if (_isShowingGameOver) return;
    _isShowingGameOver = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGameOverDialog(),
    ).then((_) => _isShowingGameOver = false);
  }

  Widget _buildGameOverDialog() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: GameConfig.danger, width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.heart_broken_rounded,
                        color: GameConfig.danger, size: 40),
                    SizedBox(width: 8),
                    Icon(Icons.heart_broken_rounded,
                        color: GameConfig.danger, size: 56),
                    SizedBox(width: 8),
                    Icon(Icons.heart_broken_rounded,
                        color: GameConfig.danger, size: 40),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: GameConfig.danger,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: GameConfig.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Out of hearts!',
                      style: TextStyle(
                        color: GameConfig.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedScaleButton(
                  onTap: () async {
                    final rewarded = await AdService.instance.showHintAd();
                    if (rewarded) {
                      _engine.addLife();
                      _winHandled = false; // Reset for potential future win
                      if (!mounted) return;
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: GameConfig.success,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: GameConfig.cubeGreenSide,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_filled_rounded,
                            color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'WATCH AD FOR +1 LIFE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _winHandled = false;
                    _engine.restart();
                  },
                  child: const Text(
                    'TRY AGAIN',
                    style: TextStyle(
                      color: GameConfig.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onBlockTapped(ArrowBlock block) {
    if (_isProcessingTap) return;
    _isProcessingTap = true;
    final storage = Provider.of<StorageService>(context, listen: false);
    final vibEnabled = storage.userData.settings.vibrationEnabled;
    if (vibEnabled) HapticFeedback.lightImpact();
    setState(() => _highlightedBlockId = null);

    final success = _engine.moveBlock(block.id);
    if (success) {
      AudioService.instance.playSlideSound();
      if (vibEnabled) HapticFeedback.mediumImpact();
      // Win detection handled by _onEngineStateChanged to avoid double-fire
    } else {
      AudioService.instance.playTap();
      if (vibEnabled) HapticFeedback.heavyImpact();
    }
    // Release tap lock after slide animation completes
    Future.delayed(GameConfig.blockSlideDuration, () {
      _isProcessingTap = false;
    });
  }

  void _showHint() async {
    final rewarded = await AdService.instance.showHintAd();
    if (rewarded && mounted) {
      final hintBlockId = _engine.getHintBlockId();
      if (hintBlockId != null) {
        setState(() => _highlightedBlockId = hintBlockId);
        final hintBlock =
            _engine.blocks.where((b) => b.id == hintBlockId).firstOrNull;
        if (hintBlock != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '💡 Tap the ${hintBlock.direction.name.toUpperCase()} arrow!'),
            backgroundColor: GameConfig.accent,
            duration: const Duration(seconds: 2),
          ));
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Watch an ad to get a hint!'),
        backgroundColor: GameConfig.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: GameConfig.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: GameConfig.primary),
              const SizedBox(height: 16),
              Text('Loading Level ${widget.levelId}...',
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: GameConfig.backgroundDark,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_error!,
                style:
                    const TextStyle(color: GameConfig.error, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BACK')),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: GameConfig.background,
      body: DottedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListenableBuilder(
                        listenable: _engine,
                        builder: (context, _) => ListenableBuilder(
                          listenable: _shakeAnim,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(_shakeAnim.value, 0),
                            child: child,
                          ),
                          child: InteractiveViewer(
                            panEnabled: true,
                            scaleEnabled: true,
                            minScale: 0.5,
                            maxScale: 3.0,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: _buildPuzzleArea(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildBottomToolbar(),
                    // Banner Ad
                    AdService.instance.getBannerWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered Title & Timer
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LEVEL ${widget.levelId}',
                style: const TextStyle(
                  color: GameConfig.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              // Timer — uses separate ListenableBuilder to avoid rebuilding entire top bar
              ListenableBuilder(
                listenable: _engine,
                builder: (context, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: GameConfig.primary, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          _engine.elapsedFormatted,
                          style: const TextStyle(
                            color: GameConfig.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Left & Right Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              AnimatedScaleButton(
                onTap: () => Navigator.pop(context),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.arrow_back,
                        color: GameConfig.textPrimary, size: 22),
                  ),
                ),
              ),
              // Hearts (Lives) — separate ListenableBuilder
              ListenableBuilder(
                listenable: _engine,
                builder: (context, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: List.generate(3, (index) {
                        final hasLife = index < _engine.lives;
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            hasLife
                                ? Icons.favorite_rounded
                                : Icons.heart_broken_rounded,
                            color: hasLife
                                ? GameConfig.danger
                                : GameConfig.textMuted
                                    .withValues(alpha: 0.3),
                            size: 20,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleArea() {
    final availableWidth = _screenWidth - 24;
    final availableHeight = _screenHeight - 320;

    final cellW = availableWidth / _engine.gridWidth;
    final cellH = availableHeight / _engine.gridHeight;
    final cellSize = (cellW < cellH ? cellW : cellH).clamp(30.0, 68.0);

    final boardW = _engine.gridWidth * cellSize;
    final boardH = _engine.gridHeight * cellSize;

    return SizedBox(
      width: boardW + 12,
      height: boardH + 12,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Active blocks
            ..._engine.blocks.map((block) {
              return AnimatedPositioned(
                key: ValueKey(block.id),
                duration: GameConfig.blockSlideDuration,
                curve: GameConfig.blockSlideCurve,
                left: block.x * cellSize,
                top: block.y * cellSize,
                child: RepaintBoundary(
                  child: ArrowBlockWidget(
                    block: block,
                    cellSize: cellSize,
                    isHighlighted: _highlightedBlockId == block.id,
                    onTap: () => _onBlockTapped(block),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolbarButton(
            icon: Icons.undo_rounded,
            color: GameConfig.warning,
            label: 'UNDO',
            onTap: () {
              if (_engine.canUndo) {
                setState(() {
                  _engine.undo();
                  _highlightedBlockId = null;
                });
              }
            },
          ),
          _ToolbarButton(
            icon: Icons.refresh_rounded,
            color: GameConfig.primary,
            label: 'RESTART',
            onTap: () async {
              _retryCount++;
              if (_retryCount % GameConfig.retryAdFrequency == 0) {
                await AdService.instance.showInterstitialAd();
              }
              if (mounted) {
                _winHandled = false;
                setState(() {
                  _engine.restart();
                  _highlightedBlockId = null;
                });
              }
            },
          ),
          _ToolbarButton(
            icon: Icons.lightbulb_outline_rounded,
            color: GameConfig.warning,
            label: 'HINT',
            badge: '▶',
            onTap: _showHint,
          ),
        ],
      ),
    );
  }
}

/// Extracted toolbar button widget to avoid rebuilding all buttons on state changes.
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  const _ToolbarButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Icon(icon, color: color, size: 32),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: -6,
                  right: -6,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: GameConfig.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: GameConfig.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
