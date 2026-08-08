import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/ad_service.dart';
import '../utils/audio_service.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/storage_service.dart';
import '../widgets/dotted_background.dart';
import '../widgets/clay_button.dart';
import '../widgets/animated_scale_button.dart';

/// Home screen — main menu with play, levels, daily challenge, settings, about.
///
/// Uses [ListenableBuilder] instead of deprecated AnimatedBuilder.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoFloat;
  bool _isNavigating = false;

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

    _logoFloat =
        Tween<Offset>(
          begin: const Offset(0, -6),
          end: const Offset(0, 6),
        ).animate(
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
    final settings = userData.settings;

    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: DottedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Settings Gear
                    _TopBarIconButton(
                      icon: Icons.settings_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.settings),
                    ),
                    const Spacer(),
                    // Level Badge
                    _LevelBadge(level: currentLevel),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // 3D Animated Logo
                      ListenableBuilder(
                        listenable: _logoController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _logoFloat.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 1. PLAY
                      ClayButton(
                        color: GameConfig.primary,
                        depthColor: GameConfig.primaryDepth,
                        onTap: () {
                          if (_isNavigating) return;
                          _isNavigating = true;
                          Navigator.pushNamed(
                            context,
                            AppRouter.gameplay,
                            arguments: currentLevel.clamp(
                              1,
                              GameConfig.totalLevels,
                            ),
                          ).then((_) => _isNavigating = false);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'PLAY',
                              style: TextStyle(
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

                      // 2. LEVELS
                      ClayButton(
                        color: GameConfig.secondary,
                        depthColor: GameConfig.secondaryDepth,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.levelSelect),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
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

                      // 3. DAILY CHALLENGE
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
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

                      // SETTINGS & ABOUT
                      Row(
                        children: [
                          Expanded(
                            child: _SecondaryPillButton(
                              icon: Icons.settings_rounded,
                              label: 'SETTINGS',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRouter.settings,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SecondaryPillButton(
                              icon: Icons.info_outline_rounded,
                              label: 'ABOUT',
                              onTap: () =>
                                  Navigator.pushNamed(context, AppRouter.about),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bottom Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SquareIconButton(
                            icon: settings.musicEnabled
                                ? Icons.music_note_rounded
                                : Icons.music_off_rounded,
                            onTap: () {
                              setState(() {
                                final newSettings = settings.copyWith(
                                  musicEnabled: !settings.musicEnabled,
                                );
                                storage.updateSettings(newSettings);
                                AudioService.instance.setMusicEnabled(
                                  newSettings.musicEnabled,
                                );
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          _SquareIconButton(
                            icon: settings.soundEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            onTap: () {
                              setState(() {
                                final newSettings = settings.copyWith(
                                  soundEnabled: !settings.soundEnabled,
                                );
                                storage.updateSettings(newSettings);
                                AudioService.instance.setSoundEnabled(
                                  newSettings.soundEnabled,
                                );
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          _SquareIconButton(
                            icon: Icons.share_rounded,
                            onTap: () {
                              Share.share(
                                'Check out ArrowSlide 3D! The most addictive puzzle game. Download now!',
                              );
                            },
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
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: DecoratedBox(
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
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: GameConfig.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
      ),
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
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
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: GameConfig.textPrimary, size: 24),
        ),
      ),
    );
  }
}
