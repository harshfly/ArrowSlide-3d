import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/ad_service.dart';

/// Splash screen — loads assets, checks internet, initializes AdMob.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatController;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

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
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Step 1: Check internet connection

    await _simulateProgress(0.2);

    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasInternet) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.noInternet);
      }
      return;
    }

    // Step 2: Initialize AdMob

    await _simulateProgress(0.5);
    await AdService.instance.init();

    // Step 3: Load assets

    await _simulateProgress(0.8);

    // Step 4: Ready
    setState(() {

      _loadProgress = 1.0;
    });
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
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: child,
                  ),
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
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                                  color: GameConfig.primary.withValues(alpha: 0.5),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingCubes() {
    return [
      _positionedCube(
        top: 90, left: 35, size: 48,
        color: GameConfig.primary,
        rotation: 0.15,
        offsetPhase: 0.0,
        icon: Icons.arrow_upward_rounded,
      ),
      _positionedCube(
        top: 180, right: 45, size: 54,
        color: GameConfig.danger,
        rotation: -0.2,
        offsetPhase: 1.2,
        icon: Icons.arrow_forward_rounded,
      ),
      _positionedCube(
        bottom: 140, left: 50, size: 62,
        color: GameConfig.purple,
        rotation: 0.18,
        offsetPhase: 2.4,
        icon: Icons.arrow_downward_rounded,
      ),
      _positionedCube(
        bottom: 240, right: 70, size: 42,
        color: GameConfig.accent,
        rotation: -0.15,
        offsetPhase: 3.6,
        icon: Icons.arrow_back_rounded,
      ),
      _positionedCube(
        top: 340, left: 75, size: 50,
        color: GameConfig.secondary,
        rotation: 0.25,
        offsetPhase: 4.8,
        icon: Icons.arrow_upward_rounded,
      ),
      _positionedCube(
        bottom: 340, right: 35, size: 46,
        color: GameConfig.primary,
        rotation: -0.1,
        offsetPhase: 5.5,
        icon: Icons.arrow_forward_rounded,
      ),
    ];
  }

  Widget _positionedCube({
    double? top, double? bottom, double? left, double? right,
    required double size,
    required Color color,
    required double rotation,
    required double offsetPhase,
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatY = math.sin(_floatController.value * math.pi * 2 + offsetPhase) * 16.0;
        final floatRot = math.cos(_floatController.value * math.pi * 2 + offsetPhase) * 0.08;
        return Positioned(
          top: top != null ? top + floatY : null,
          bottom: bottom != null ? bottom - floatY : null,
          left: left,
          right: right,
          child: Transform.rotate(
            angle: rotation + floatRot,
            child: Opacity(
              opacity: 0.75,
              child: _buildSimpleCube(size, color, icon),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleCube(double size, Color color, IconData icon) {
    final depth = size * 0.2;
    return SizedBox(
      width: size,
      height: size + depth,
      child: Stack(
        children: [
          // Front face
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.95),
                size: size * 0.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
