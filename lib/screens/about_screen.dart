import 'package:flutter/material.dart';
import '../config.dart';
import '../widgets/animated_scale_button.dart';

/// About screen — game information, version, developer credits, rate us, share.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(GameConfig.spacingMd),
              child: Row(
                children: [
                  AnimatedScaleButton(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: GameConfig.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GameConfig.surfaceLight, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: GameConfig.textColor),
                    ),
                  ),
                  const SizedBox(width: GameConfig.spacingMd),
                  Text(
                    'ABOUT',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(GameConfig.spacingXl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: GameConfig.spacingMd),
                      Text(
                        'Version ${GameConfig.appVersion}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: GameConfig.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: GameConfig.spacingXl),

                      // Description
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(GameConfig.spacingLg),
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
                        child: Column(
                          children: [
                            Text(
                              GameConfig.gameDescription,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: GameConfig.spacingMd),
                            Divider(color: GameConfig.surfaceLight, thickness: 1.5),
                            const SizedBox(height: GameConfig.spacingMd),
                            Text(
                              'Developed with ❤️ using Flutter',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              GameConfig.copyright,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GameConfig.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: GameConfig.spacingXl),

                      // Rate Us & Share
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.star_rounded,
                              label: 'RATE US',
                              color: GameConfig.warning,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Thank you for your support! ⭐'),
                                    backgroundColor: GameConfig.surface,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(GameConfig.radiusSm),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: GameConfig.spacingMd),
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.share_rounded,
                              label: 'SHARE',
                              color: GameConfig.primary,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Share feature coming soon!'),
                                    backgroundColor: GameConfig.surface,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(GameConfig.radiusSm),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCubeLogo() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 5, right: 5, child: _buildCube(36, GameConfig.error, GameConfig.obstacleBlockSide)),
          Positioned(top: 20, left: 8, child: _buildCube(32, GameConfig.warning, GameConfig.keyBlockSide)),
          Positioned(bottom: 0, left: 12, child: _buildCube(42, GameConfig.primary, GameConfig.playerBlockSide)),
          Positioned(top: 0, left: 0, child: _buildCube(22, GameConfig.accent, GameConfig.rotBlockSide)),
          Positioned(bottom: 10, right: 0, child: _buildCube(28, GameConfig.purple, GameConfig.genericBlockSide)),
        ],
      ),
    );
  }

  Widget _buildCube(double size, Color front, Color side) {
    final offset = size * 0.15;
    return SizedBox(
      width: size + offset,
      height: size + offset,
      child: Stack(
        children: [
          Positioned(
            top: offset, left: 0,
            child: Container(
              width: size, height: size,
              decoration: BoxDecoration(
                color: front,
                borderRadius: BorderRadius.circular(size * 0.15),
              ),
              child: Center(
                child: Icon(Icons.arrow_upward_rounded, size: size * 0.4, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ),
          ),
          Positioned(
            top: 0, left: offset * 0.5,
            child: Container(
              width: size, height: offset,
              decoration: BoxDecoration(
                color: front.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(3)),
              ),
            ),
          ),
          Positioned(
            top: offset * 0.5, right: 0,
            child: Container(
              width: offset, height: size,
              decoration: BoxDecoration(
                color: side,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
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
