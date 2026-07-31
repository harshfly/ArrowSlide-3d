import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/ad_service.dart';
import '../widgets/animated_scale_button.dart';

/// Victory screen — LEVEL COMPLETE with star rating, coins reward, next level / replay.
class VictoryScreen extends StatefulWidget {
  final int levelId;
  final int moves;
  final int stars;

  const VictoryScreen({
    super.key,
    required this.levelId,
    required this.moves,
    required this.stars,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;

  int get _starCount {
    return widget.stars;
  }



  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _controller = AnimationController(
      vsync: this,
      duration: GameConfig.starAnimationDuration,
    );
    
    // Play stars animation with haptics
    _controller.addListener(() {
      // Simulate popping effect on star intervals (roughly 0.33, 0.66, 1.0)
    });
    
    _controller.forward().then((_) {
      if (_starCount == 3) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStar(0, 48, -10),
                      _buildStar(1, 64, -20),
                      _buildStar(2, 48, -10),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Title
                  const Text(
                    'LEVEL CLEARED!',
                    style: TextStyle(
                      color: GameConfig.danger,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Perfect Clear Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: GameConfig.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _starCount == 3 ? Icons.check_circle_rounded : Icons.star_rounded, 
                          color: _starCount == 3 ? GameConfig.success : GameConfig.warning, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _starCount == 3 ? 'Perfect Clear' : 'Cleared',
                          style: TextStyle(
                            color: _starCount == 3 ? GameConfig.success : GameConfig.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  AnimatedScaleButton(
                    onTap: () => Navigator.pushReplacementNamed(
                      context, AppRouter.gameplay,
                      arguments: widget.levelId + 1,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        color: GameConfig.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: GameConfig.cubeBlueSide, // Darker bottom edge
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'NEXT LEVEL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.1,
            numberOfParticles: 40,
            gravity: 0.3,
            minimumSize: const Size(8, 4),
            maximumSize: const Size(15, 8),
            colors: const [GameConfig.primary, GameConfig.danger, GameConfig.warning, GameConfig.success],
          ),
        ],
      ),
      bottomNavigationBar: _buildBannerAd(),
    );
  }

  Widget _buildStar(int index, double size, double yOffset) {
    final isActive = index < _starCount;
    return Transform.translate(
      offset: Offset(0, yOffset),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.2 + index * 0.15,
            (0.5 + index * 0.15).clamp(0.0, 1.0),
            curve: Curves.elasticOut,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            isActive ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: isActive ? GameConfig.warning : GameConfig.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildBannerAd() {
    if (!GameConfig.showBannerOnVictory) return const SizedBox.shrink();
    return Container(
      color: GameConfig.backgroundDark,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SafeArea(
        top: false,
        child: AdService.instance.isInitialized
            ? AdService.instance.getBannerWidget()
            : const SizedBox(height: 50),
      ),
    );
  }
}
