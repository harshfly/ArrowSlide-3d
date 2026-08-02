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
                            const Divider(color: GameConfig.surfaceLight, thickness: 1.5),
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
