import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/daily_challenge_service.dart';
import '../widgets/clay_button.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/dotted_background.dart';

/// Daily Challenge Screen — high-difficulty daily puzzle challenge lobby.
class DailyRewardScreen extends StatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: DottedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(GameConfig.spacingMd),
                child: Row(
                  children: [
                    AnimatedScaleButton(
                      onTap: () => Navigator.pop(context),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: GameConfig.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: GameConfig.surfaceLight, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.arrow_back_rounded,
                              color: GameConfig.textPrimary, size: 22),
                        ),
                      ),
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: GameConfig.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: GameConfig.danger, width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.whatshot_rounded,
                                color: GameConfig.danger, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'DAY #${DailyChallengeService.getTodaySeed()}',
                              style: const TextStyle(
                                color: GameConfig.danger,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Animated Challenge Trophy Card
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                GameConfig.warning,
                                GameConfig.danger
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: GameConfig.danger
                                    .withValues(alpha: 0.35),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const SizedBox(
                            width: 140,
                            height: 140,
                            child: Center(
                              child: Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 72,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        'DAILY CHALLENGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DailyChallengeService.getFormattedTodayDate(),
                        style: const TextStyle(
                          color: GameConfig.warning,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          child: Text(
                            'Next new puzzle in: ${DailyChallengeService.getTimeUntilNextChallenge()}',
                            style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Challenge Details Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: GameConfig.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: GameConfig.surfaceLight, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              icon: Icons.grid_on_rounded,
                              color: GameConfig.primary,
                              title: 'Grid Dimensions',
                              value: '7 x 7 Advanced Grid',
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                  color: GameConfig.surfaceLight,
                                  thickness: 1.5),
                            ),
                            _buildDetailRow(
                              icon: Icons.shield_rounded,
                              color: GameConfig.danger,
                              title: 'Difficulty Rating',
                              value: 'Expert / Higher Side',
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                  color: GameConfig.surfaceLight,
                                  thickness: 1.5),
                            ),
                            _buildDetailRow(
                              icon: Icons.timer_rounded,
                              color: GameConfig.warning,
                              title: 'Time Limit',
                              value: '120 Seconds',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),

              // Bottom Play Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: ClayButton(
                  color: GameConfig.danger,
                  depthColor: GameConfig.dangerDepth,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.gameplay,
                      arguments: 999,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'START CHALLENGE',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: GameConfig.textPrimary.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: GameConfig.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
