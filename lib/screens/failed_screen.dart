import 'package:flutter/material.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/ad_service.dart';
import '../widgets/animated_scale_button.dart';

/// Game Over / Level Failed screen — Sad cube illustration, Retry, Undo, Hint (Rewarded Ad), Home.
class FailedScreen extends StatelessWidget {
  final int levelId;
  final int moves;
  final int bestMoves;

  const FailedScreen({
    super.key,
    required this.levelId,
    this.moves = 0,
    this.bestMoves = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: GameConfig.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Banner title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: GameConfig.danger,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: GameConfig.danger.withValues(alpha: 0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: const Text(
                    'LEVEL STUCK!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: GameConfig.spacingLg),

                // Sad Cube Illustration
                _buildSadCube(),
                const SizedBox(height: GameConfig.spacingLg),

                // Stats Card
                Container(
                  padding: const EdgeInsets.all(GameConfig.spacingMd),
                  decoration: BoxDecoration(
                    color: GameConfig.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: GameConfig.surfaceLight, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('MOVES', '$moves'),
                      Container(width: 1.5, height: 36, color: GameConfig.surfaceLight),
                      _buildStatColumn('BEST', '$bestMoves'),
                    ],
                  ),
                ),
                const SizedBox(height: GameConfig.spacingXxl),

                // Retry Button
                _buildButton(
                  context,
                  label: 'RETRY LEVEL',
                  icon: Icons.refresh_rounded,
                  color: GameConfig.primary,
                  onTap: () => Navigator.pushReplacementNamed(
                    context, AppRouter.gameplay,
                    arguments: levelId,
                  ),
                ),
                const SizedBox(height: GameConfig.spacingMd),

                // Hint (Rewarded Ad) Button
                _buildButton(
                  context,
                  label: 'HINT (+1 WATCH AD)',
                  icon: Icons.play_circle_filled_rounded,
                  color: GameConfig.accent,
                  onTap: () async {
                    final rewarded = await AdService.instance.showHintAd();
                    if (rewarded && context.mounted) {
                      Navigator.pushReplacementNamed(
                        context, AppRouter.gameplay,
                        arguments: levelId,
                      );
                    }
                  },
                ),
                const SizedBox(height: GameConfig.spacingMd),

                // Home Button
                _buildButton(
                  context,
                  label: 'HOME',
                  icon: Icons.home_rounded,
                  color: GameConfig.surfaceLight,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRouter.home,
                    (route) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSadCube() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: GameConfig.cubeRed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: GameConfig.cubeRed.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: GameConfig.cubeRedSide,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 24),
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 16),
            // Sad mouth curve
            Transform.rotate(
              angle: 3.1416,
              child: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: GameConfig.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
