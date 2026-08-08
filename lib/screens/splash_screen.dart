import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/ad_service.dart';

/// Splash screen — loads assets, checks internet, initializes AdMob.
///
/// Uses [ListenableBuilder] instead of deprecated AnimatedBuilder.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _floatController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  double _loadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Step 1: Check internet connection
    await _simulateProgress(0.2);
    if (!mounted) return;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

      if (!hasInternet) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRouter.noInternet);
        }
        return;
      }
    } catch (_) {
      // Connectivity check failed — proceed anyway (graceful offline)
    }

    // Step 2: Initialize AdMob
    await _simulateProgress(0.5);
    if (!mounted) return;
    await AdService.instance.init();

    // Step 3: Load assets
    await _simulateProgress(0.8);
    if (!mounted) return;

    // Step 4: Ready
    setState(() => _loadProgress = 1.0);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    }
  }

  Future<void> _simulateProgress(double target) async {
    while (_loadProgress < target) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() {
        _loadProgress = (_loadProgress + 0.05).clamp(0.0, target);
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: Stack(
        children: [
          // Background animated floating arrows
          ..._buildFloatingCubes(),

          Center(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.scale(scale: _scale.value, child: child),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 60),

                  // Progress bar
                  Text(
                    'LOADING...',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const SizedBox(height: 6, width: 220),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: 220 * _loadProgress,
                            height: 6,
                            decoration: BoxDecoration(
                              color: GameConfig.primary,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: GameConfig.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_loadProgress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Version text at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'v${GameConfig.appVersion}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingCubes() {
    return [
      _positionedArrow(
        top: 80,
        left: 30,
        size: 54,
        color: GameConfig.primary,
        direction: 'up',
        offsetPhase: 0.0,
        icon: Icons.arrow_upward_rounded,
      ),
      _positionedArrow(
        top: 160,
        right: 35,
        size: 58,
        color: GameConfig.danger,
        direction: 'right',
        offsetPhase: 0.15,
        icon: Icons.arrow_forward_rounded,
      ),
      _positionedArrow(
        bottom: 150,
        left: 45,
        size: 62,
        color: GameConfig.purple,
        direction: 'down',
        offsetPhase: 0.30,
        icon: Icons.arrow_downward_rounded,
      ),
      _positionedArrow(
        bottom: 230,
        right: 50,
        size: 52,
        color: GameConfig.accent,
        direction: 'left',
        offsetPhase: 0.45,
        icon: Icons.arrow_back_rounded,
      ),
      _positionedArrow(
        top: 300,
        left: 75,
        size: 56,
        color: GameConfig.secondary,
        direction: 'up',
        offsetPhase: 0.60,
        icon: Icons.arrow_upward_rounded,
      ),
      _positionedArrow(
        bottom: 320,
        right: 35,
        size: 54,
        color: GameConfig.primary,
        direction: 'right',
        offsetPhase: 0.75,
        icon: Icons.arrow_forward_rounded,
      ),
      _positionedArrow(
        top: 220,
        left: 140,
        size: 50,
        color: GameConfig.warning,
        direction: 'left',
        offsetPhase: 0.85,
        icon: Icons.arrow_back_rounded,
      ),
    ];
  }

  Widget _positionedArrow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required String direction,
    required double offsetPhase,
    required IconData icon,
  }) {
    return ListenableBuilder(
      listenable: _floatController,
      builder: (context, child) {
        final t = (_floatController.value + offsetPhase) % 1.0;

        double dx = 0.0;
        double dy = 0.0;
        double opacity = 0.9;

        if (t <= 0.35) {
          dy = math.sin(t * math.pi * 4) * 6.0;
        } else {
          final progress = (t - 0.35) / 0.65;
          final curve = Curves.easeInCubic.transform(progress);
          final dist = curve * 700.0;

          if (direction == 'up') dy = -dist;
          if (direction == 'down') dy = dist;
          if (direction == 'left') dx = -dist;
          if (direction == 'right') dx = dist;

          if (progress > 0.85) {
            opacity = 0.9 * (1.0 - (progress - 0.85) / 0.15);
          }
        }

        return Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: child),
          ),
        );
      },
      child: _buildLevelArrowCube(size, color, icon),
    );
  }

  Widget _buildLevelArrowCube(double size, Color color, IconData icon) {
    final depthY = size * 0.18;
    final hsl = HSLColor.fromColor(color);
    final darkerColor = hsl
        .withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0))
        .toColor();
    final lighterColor = hsl
        .withLightness((hsl.lightness * 1.15).clamp(0.0, 1.0))
        .toColor();

    return SizedBox(
      width: size,
      height: size + depthY,
      child: Stack(
        children: [
          // Soft drop shadow
          Positioned(
            top: depthY + 3,
            left: 2,
            right: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SizedBox(height: size),
            ),
          ),

          // 3D Depth Layer
          Positioned(
            top: depthY,
            left: 0,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: darkerColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(height: size),
            ),
          ),

          // Main Face Layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [lighterColor, color],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Glossy top inner sheen
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.32),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: SizedBox(height: size * 0.42),
                    ),
                  ),
                  // Direction Arrow Icon
                  Center(
                    child: Icon(icon, color: Colors.white, size: size * 0.55),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
