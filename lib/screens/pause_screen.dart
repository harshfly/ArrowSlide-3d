import 'dart:ui';
import 'package:flutter/material.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../widgets/animated_scale_button.dart';

/// Pause Overlay Screen — Glassmorphism popup with backdrop blur.
class PauseScreen extends StatelessWidget {
  const PauseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Stack(
        children: [
          // Glassmorphism Backdrop Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GameConfig.spacingXl),
              child: Container(
                padding: const EdgeInsets.all(GameConfig.spacingLg),
                decoration: BoxDecoration(
                  color: GameConfig.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Text(
                      'PAUSED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: GameConfig.spacingLg),

                    // Resume
                    _buildButton(
                      context,
                      label: 'RESUME',
                      icon: Icons.play_arrow_rounded,
                      color: GameConfig.primary,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: GameConfig.spacingSm),

                    // Restart
                    _buildButton(
                      context,
                      label: 'RESTART',
                      icon: Icons.refresh_rounded,
                      color: GameConfig.accent,
                      onTap: () {
                        // Normally this would trigger a restart in gameplay_screen
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: GameConfig.spacingSm),

                    // Settings
                    _buildButton(
                      context,
                      label: 'SETTINGS',
                      icon: Icons.settings_rounded,
                      color: GameConfig.surfaceLight,
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.settings);
                      },
                    ),
                    const SizedBox(height: GameConfig.spacingSm),

                    // Home
                    _buildButton(
                      context,
                      label: 'HOME',
                      icon: Icons.home_rounded,
                      color: GameConfig.surfaceLight,
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.home,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
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
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
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
