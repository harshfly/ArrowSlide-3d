import 'dart:async';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: Stack(
        children: [
          // Background floating cubes
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
    // Generate some static floating cubes in the background for effect
    // In a full implementation, these would use an AnimationController for slow bobbing
    return [
      _positionedCube(top: 100, left: 40, size: 40, color: GameConfig.primary, rotation: 0.2),
      _positionedCube(top: 200, right: 50, size: 50, color: GameConfig.danger, rotation: -0.15),
      _positionedCube(bottom: 150, left: 60, size: 60, color: GameConfig.purple, rotation: 0.1),
      _positionedCube(bottom: 250, right: 80, size: 35, color: GameConfig.accent, rotation: -0.2),
      _positionedCube(top: 350, left: 80, size: 45, color: GameConfig.secondary, rotation: 0.3),
    ];
  }

  Widget _positionedCube({
    double? top, double? bottom, double? left, double? right,
    required double size, required Color color, required double rotation
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: 0.6,
          child: _buildSimpleCube(size, color),
        ),
      ),
    );
  }

  Widget _buildSimpleCube(double size, Color color) {
    final depth = size * 0.15;
    return SizedBox(
      width: size + depth,
      height: size + depth,
      child: Stack(
        children: [
          // Front face
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: size * 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
