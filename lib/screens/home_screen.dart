import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/storage_service.dart';
import '../widgets/dotted_background.dart';
import '../widgets/clay_button.dart';
import '../widgets/animated_scale_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final userData = storage.userData;
    final currentLevel = userData.currentProgress + 1;

    return DottedBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Settings Gear
                  _buildIconButton(
                    icon: Icons.settings_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRouter.settings),
                  ),
                  const Spacer(),
                  // Coins Pill
                  _buildCurrencyPill(
                    icon: Icons.monetization_on_rounded,
                    iconColor: GameConfig.accent,
                    value: '${userData.coins}',
                  ),
                  const SizedBox(width: 8),
                  // Gems Pill with + button
                  _buildCurrencyPill(
                    icon: Icons.diamond_rounded,
                    iconColor: Colors.blueAccent,
                    value: '35',
                    hasPlus: true,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Logo Image
                    Image.asset(
                      'assets/images/logo.png',
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    // 1. PLAY (Blue Pill Button)
                    ClayButton(
                      color: GameConfig.primary,
                      depthColor: GameConfig.primaryDepth,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.gameplay,
                          arguments: currentLevel.clamp(1, GameConfig.totalLevels),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                          const SizedBox(width: 8),
                          Text(
                            'PLAY',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. LEVELS (Green Pill Button)
                    ClayButton(
                      color: GameConfig.secondary,
                      depthColor: GameConfig.secondaryDepth,
                      onTap: () => Navigator.pushNamed(context, AppRouter.levelSelect),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'LEVELS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. DAILY CHALLENGE (Coral/Red Pill Button)
                    ClayButton(
                      color: GameConfig.danger,
                      depthColor: GameConfig.dangerDepth,
                      onTap: () => Navigator.pushNamed(context, AppRouter.dailyReward),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.calendar_month_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'DAILY CHALLENGE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. STORE (Yellow/Orange Pill Button)
                    ClayButton(
                      color: GameConfig.accent,
                      depthColor: GameConfig.accentDepth,
                      onTap: () {
                        // Navigate to store / hints
                        Navigator.pushNamed(context, AppRouter.dailyReward);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'STORE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SETTINGS & ABOUT Pill Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryPillButton(
                            icon: Icons.settings_rounded,
                            label: 'SETTINGS',
                            onTap: () => Navigator.pushNamed(context, AppRouter.settings),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSecondaryPillButton(
                            icon: Icons.info_outline_rounded,
                            label: 'ABOUT',
                            onTap: () => Navigator.pushNamed(context, AppRouter.about),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bottom Icons (Music, Sound, Share)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSquareIconButton(
                          icon: Icons.music_note_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildSquareIconButton(
                          icon: Icons.volume_up_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildSquareIconButton(
                          icon: Icons.share_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // AdMob Banner Placeholder
            Container(
              height: 52,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.9),
              child: Center(
                child: Text(
                  'AdMob Banner Placeholder',
                  style: TextStyle(
                    color: GameConfig.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: GameConfig.textPrimary, size: 22),
      ),
    );
  }

  Widget _buildCurrencyPill({
    required IconData icon,
    required Color iconColor,
    required String value,
    bool hasPlus = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: GameConfig.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          if (hasPlus) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: GameConfig.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecondaryPillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: GameConfig.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: GameConfig.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: GameConfig.textPrimary, size: 22),
      ),
    );
  }
}
