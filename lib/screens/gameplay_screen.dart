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
class GameplayScreen extends StatefulWidget {
  final int levelId;
  const GameplayScreen({super.key, required this.levelId});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with TickerProviderStateMixin {
  late GameEngine _engine;
  bool _isLoading = true;
  String? _error;
  String? _highlightedBlockId;


  // Shake animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _engine.addListener(_onEngineStateChanged);
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
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
  void dispose() {
    _engine.removeListener(_onEngineStateChanged);
    _engine.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadLevelData() async {
    try {
      final level = await LevelLoader.loadLevel(widget.levelId);
      _engine.loadLevel(level);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load level ${widget.levelId}';
      });
    }
  }

  void _onEngineStateChanged() {
    if (_engine.invalidTapTriggered) {
      HapticFeedback.vibrate();
      AudioService.instance.playFailSound();
      _shakeController.forward(from: 0);
    }
    if (_engine.isWon) {
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
    // Show interstitial every 3 levels
    if (widget.levelId % GameConfig.interstitialFrequency == 0) {
      await AdService.instance.showInterstitialAd();
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.victory, arguments: {
      'levelId': widget.levelId,
      'moves': _engine.moveCount,
      'stars': _engine.starRating,
      'coinsEarned': 20 + (_engine.starRating * 10),
      'bestMoves': _engine.moveCount,
      'elapsedSec': _engine.elapsedSeconds,
    });
  }

  void _onLevelFailed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGameOverDialog(),
    );
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
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.heart_broken_rounded, color: GameConfig.danger, size: 40),
                    const SizedBox(width: 8),
                    const Icon(Icons.heart_broken_rounded, color: GameConfig.danger, size: 56),
                    const SizedBox(width: 8),
                    const Icon(Icons.heart_broken_rounded, color: GameConfig.danger, size: 40),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: GameConfig.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Out of hearts!',
                    style: TextStyle(
                      color: GameConfig.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedScaleButton(
                  onTap: () async {
                    final rewarded = await AdService.instance.showHintAd();
                    if (rewarded) {
                      _engine.addLife();
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
                      boxShadow: [
                        BoxShadow(
                          color: GameConfig.cubeGreenSide,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 24),
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
    setState(() => _highlightedBlockId = null);

    final success = _engine.moveBlock(block.id);
    if (success) {
      AudioService.instance.playSlideSound();
      HapticFeedback.lightImpact();
      // Block removal/animation is handled internally by GameEngine
      if (_engine.isWon) {
        AudioService.instance.playWinSound();
        _onLevelWon();
      }
    }
  }

  void _showHint() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    bool shouldShow = false;

    if (storage.userData.hints > 0) {
      await storage.useHint();
      shouldShow = true;
    } else {
      final rewarded = await AdService.instance.showHintAd();
      if (rewarded) {
        shouldShow = true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to load Ad. Try again later!'),
            backgroundColor: GameConfig.danger,
          ));
        }
      }
    }

    if (shouldShow && mounted) {
      final movable =
          _engine.blocks.where((b) => _engine.canBlockMove(b)).toList();
      if (movable.isNotEmpty) {
        final hintBlock = movable.first;
        setState(() => _highlightedBlockId = hintBlock.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '💡 Tap the ${hintBlock.direction.name.toUpperCase()} arrow!'),
            backgroundColor: GameConfig.accent,
            duration: const Duration(seconds: 2),
          ));
        }
      }
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
                  style: const TextStyle(color: Colors.white60, fontSize: 14)),
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
                style: const TextStyle(color: GameConfig.error, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BACK')),
          ]),
        ),
      );
    }

    final storage = Provider.of<StorageService>(context, listen: false);

    return Scaffold(
      backgroundColor: GameConfig.background,
      body: DottedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(storage),
            Expanded(
              child: AnimatedBuilder(
                animation: _engine,
                builder: (context, _) => Column(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
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
                    _buildBottomToolbar(),
                    // Banner Ad
                    AdService.instance.getBannerWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTopBar(StorageService storage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back Button
          AnimatedScaleButton(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
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
              child: const Icon(Icons.arrow_back, color: GameConfig.textPrimary, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          // Level Title
          Text('LEVEL ${widget.levelId}',
            style: const TextStyle(
              color: GameConfig.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Hearts (Lives)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            child: Row(
              children: List.generate(3, (index) {
                final hasLife = index < _engine.lives;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    hasLife ? Icons.favorite_rounded : Icons.heart_broken_rounded,
                    color: hasLife ? GameConfig.danger : GameConfig.textMuted.withValues(alpha: 0.3),
                    size: 20,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPuzzleArea() {
    final screenWidth = MediaQuery.of(context).size.width - 24;
    final screenHeight = MediaQuery.of(context).size.height - 320;

    final cellW = screenWidth / _engine.gridWidth;
    final cellH = screenHeight / _engine.gridHeight;
    final cellSize = (cellW < cellH ? cellW : cellH).clamp(30.0, 68.0);

    final boardW = _engine.gridWidth * cellSize;
    final boardH = _engine.gridHeight * cellSize;

    return Container(
      width: boardW + 12,
      height: boardH + 12,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.all(6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Active blocks
          ..._engine.blocks.map((block) {
            return AnimatedPositioned(
              key: ValueKey(block.id),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: block.x * cellSize,
              top: block.y * cellSize,
              child: ArrowBlockWidget(
                block: block,
                cellSize: cellSize,
                isHighlighted: _highlightedBlockId == block.id,
                onTap: () => _onBlockTapped(block),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
    final storage = Provider.of<StorageService>(context);
    final hintsCount = storage.userData.hints;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarButton(
            icon: Icons.undo_rounded,
            color: GameConfig.warning,
            label: 'UNDO',
            onTap: () {
              // TODO: Implement undo logic in GameEngine if desired
            },
          ),
          _buildToolbarButton(
            icon: Icons.refresh_rounded,
            color: GameConfig.primary,
            label: 'RESTART',
            onTap: () {
              setState(() {
                _engine.restart();
                _highlightedBlockId = null;
              });
            },
          ),
          _buildToolbarButton(
            icon: Icons.lightbulb_outline_rounded,
            color: GameConfig.warning,
            label: 'HINT',
            badge: hintsCount > 0 ? hintsCount.toString() : '+',
            onTap: _showHint,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    String? badge,
  }) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
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
                child: Icon(icon, color: color, size: 32),
              ),
              if (badge != null)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: GameConfig.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
