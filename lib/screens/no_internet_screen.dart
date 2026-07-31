import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/ad_service.dart';
import '../widgets/animated_scale_button.dart';

/// Full-screen "No Internet" page with a Retry button.
/// Does not allow gameplay until connectivity returns and AdMob initializes.
class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  bool _isRetrying = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (hasInternet) {
      // Try to initialize AdMob
      final adInitialized = await AdService.instance.init();
      if (mounted) {
        if (adInitialized) {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        } else {
          // AdMob failed but internet is there — allow entry anyway
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
      }
    } else {
      if (mounted) {
        setState(() => _isRetrying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Still no internet connection'),
            backgroundColor: GameConfig.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GameConfig.radiusSm),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GameConfig.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated wifi-off icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.08),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: GameConfig.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: GameConfig.error.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: GameConfig.error,
                    ),
                  ),
                ),
                const SizedBox(height: GameConfig.spacingXl),
                Text(
                  'No Internet',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: GameConfig.spacingMd),
                Text(
                  'An internet connection is required to play.\n'
                  'Please check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: GameConfig.textMuted,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: GameConfig.spacingXxl),
                AnimatedScaleButton(
                  onTap: _isRetrying ? () {} : _retry,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: GameConfig.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: GameConfig.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: _isRetrying
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh_rounded, size: 24, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'RETRY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
