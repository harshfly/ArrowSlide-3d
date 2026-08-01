import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/ad_service.dart';
import '../utils/storage_service.dart';
import '../widgets/dotted_background.dart';
import '../widgets/clay_button.dart';
import '../widgets/animated_scale_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoFloat;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine),
    );

    _logoFloat = Tween<Offset>(begin: const Offset(0, -6), end: const Offset(0, 6)).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

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
                  // Level Badge
                  _buildLevelBadge(level: currentLevel),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // 3D Animated Logo (Pops slowly for an immersive feel without blue background box)
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _logoFloat.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 170,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
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
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushNamed(
                          context,
                          AppRouter.gameplay,
                          arguments: 999,
                        );
                      },
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

            // AdMob Banner
            if (GameConfig.showBannerOnHome)
              AdService.instance.getBannerWidget(),
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

  Widget _buildLevelBadge({required int level}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: GameConfig.warning.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: GameConfig.warning, size: 20),
          const SizedBox(width: 8),
          Text(
            'LEVEL $level',
            style: const TextStyle(
              color: GameConfig.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
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
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: GameConfig.textPrimary, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: GameConfig.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
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
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: GameConfig.textPrimary, size: 24),
      ),
    );
  }
}
