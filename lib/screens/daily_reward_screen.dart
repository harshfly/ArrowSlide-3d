import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../utils/storage_service.dart';
import '../utils/ad_service.dart';
import '../widgets/animated_scale_button.dart';

/// Daily Reward Screen — local reward cycle without backend.
class DailyRewardScreen extends StatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _claimed = false;
  Map<String, dynamic>? _reward;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    if (_claimed) return;

    final storage = Provider.of<StorageService>(context, listen: false);
    if (!storage.userData.isDailyRewardAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Come back tomorrow for your next reward!'),
            backgroundColor: GameConfig.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GameConfig.radiusSm),
            ),
          ),
        );
      }
      return;
    }

    final reward = await storage.claimDailyReward();
    setState(() {
      _claimed = true;
      _reward = reward;
    });
  }

  String _getNextRewardTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context, listen: false);
    final userData = storage.userData;
    final currentDay = userData.dailyRewardDay;
    final isAvailable = userData.isDailyRewardAvailable;

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
                  const Spacer(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GameConfig.spacingXl),
                child: Column(
                  children: [
                    // Title
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          color: GameConfig.purple,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: GameConfig.purple.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                        ),
                        child: const Text(
                          'DAILY CHALLENGE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: GameConfig.spacingMd),

                    // Next challenge timer
                    if (!isAvailable && !_claimed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: GameConfig.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: GameConfig.surfaceLight, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_rounded, size: 20, color: GameConfig.accent),
                            const SizedBox(width: 8),
                            const Text(
                              'NEXT CHALLENGE IN',
                              style: TextStyle(
                                color: GameConfig.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getNextRewardTime(),
                              style: const TextStyle(
                                color: GameConfig.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: GameConfig.spacingLg),

                    // 7-day reward grid
                    _buildRewardGrid(currentDay),
                    const SizedBox(height: GameConfig.spacingLg),

                    // Today's reward card
                    _buildTodayReward(currentDay),
                    const SizedBox(height: GameConfig.spacingXxl),

                    // Claim / Play button
                    if (isAvailable && !_claimed)
                      AnimatedScaleButton(
                        onTap: _claimReward,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: GameConfig.success,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: GameConfig.success.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'CLAIM REWARD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (_claimed && _reward != null)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(GameConfig.spacingMd),
                            decoration: BoxDecoration(
                              color: GameConfig.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: GameConfig.success.withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 48, color: GameConfig.success),
                                const SizedBox(height: 8),
                                const Text('Reward Claimed!', style: TextStyle(
                                  color: GameConfig.success,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                )),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if ((_reward!['coins'] as int?) != null && (_reward!['coins'] as int) > 0) ...[
                                      const Icon(Icons.monetization_on_rounded, size: 24, color: GameConfig.warning),
                                      const SizedBox(width: 6),
                                      Text('+${_reward!['coins']}', style: const TextStyle(
                                        color: GameConfig.warning, fontWeight: FontWeight.w800, fontSize: 18,
                                      )),
                                      const SizedBox(width: 24),
                                    ],
                                    if ((_reward!['hints'] as int?) != null && (_reward!['hints'] as int) > 0) ...[
                                      const Icon(Icons.lightbulb_rounded, size: 24, color: GameConfig.accent),
                                      const SizedBox(width: 6),
                                      Text('+${_reward!['hints']}', style: const TextStyle(
                                        color: GameConfig.accent, fontWeight: FontWeight.w800, fontSize: 18,
                                      )),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: GameConfig.spacingLg),
                          AnimatedScaleButton(
                            onTap: () => Navigator.pop(context),
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
                              child: const Center(
                                child: Text('CONTINUE', style: TextStyle(
                                  color: Colors.white, fontSize: 18,
                                  fontWeight: FontWeight.w800, letterSpacing: 1.5,
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: GameConfig.spacingLg),
                  ],
                ),
              ),
            ),

            // Banner ad
            Container(
              color: GameConfig.backgroundDark,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AdService.instance.isInitialized
                  ? AdService.instance.getBannerWidget()
                  : const SizedBox(height: 50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardGrid(int currentDay) {
    return Wrap(
      spacing: GameConfig.spacingSm,
      runSpacing: GameConfig.spacingSm,
      children: List.generate(GameConfig.dailyRewardCycleDays, (i) {
        final reward = GameConfig.dailyRewards[i];
        final isPast = i < currentDay;
        final isCurrent = i == currentDay;

        return Container(
          width: 72,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCurrent
                ? GameConfig.primary.withValues(alpha: 0.2)
                : isPast
                    ? GameConfig.success.withValues(alpha: 0.1)
                    : GameConfig.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent
                  ? GameConfig.primary
                  : isPast
                      ? GameConfig.success.withValues(alpha: 0.3)
                      : GameConfig.surfaceLight,
              width: isCurrent ? 2 : 1.5,
            ),
            boxShadow: isCurrent ? [
              BoxShadow(
                color: GameConfig.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Column(
            children: [
              Text(
                'Day ${i + 1}',
                style: TextStyle(
                  color: isCurrent ? GameConfig.primary : GameConfig.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              if (isPast)
                const Icon(Icons.check_circle_rounded, size: 24, color: GameConfig.success)
              else ...[
                Icon(
                  Icons.monetization_on_rounded,
                  size: 20,
                  color: isCurrent ? GameConfig.warning : GameConfig.textMuted,
                ),
                const SizedBox(height: 2),
                Text(
                  '${reward['coins']}',
                  style: TextStyle(
                    color: isCurrent ? GameConfig.warning : GameConfig.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTodayReward(int currentDay) {
    final todayReward = GameConfig.dailyRewards[currentDay % GameConfig.dailyRewardCycleDays];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GameConfig.spacingMd),
      decoration: BoxDecoration(
        color: GameConfig.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameConfig.primary.withValues(alpha: 0.3), width: 1.5),
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
          const Text("TODAY'S REWARD", style: TextStyle(
            color: GameConfig.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on_rounded, size: 32, color: GameConfig.warning),
              const SizedBox(width: 8),
              Text('${todayReward['coins']}', style: const TextStyle(
                color: GameConfig.warning,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              )),
              if ((todayReward['hints'] as int?) != null && (todayReward['hints'] as int) > 0) ...[
                const SizedBox(width: 32),
                const Icon(Icons.lightbulb_rounded, size: 32, color: GameConfig.accent),
                const SizedBox(width: 8),
                Text('${todayReward['hints']}', style: const TextStyle(
                  color: GameConfig.accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                )),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
