import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../utils/app_router.dart';
import '../utils/ad_service.dart';
import '../utils/storage_service.dart';
import '../widgets/dotted_background.dart';
import '../widgets/animated_scale_button.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _selectedChapter = 0;

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final userData = storage.userData;

    return DottedBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  AnimatedScaleButton(
                    onTap: () => Navigator.pop(context),
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: GameConfig.textPrimary),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'LEVELS',
                        style: TextStyle(
                          color: GameConfig.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // balance back button
                ],
              ),
            ),

            // Chapter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: List.generate(GameConfig.chaptersCount, (index) {
                  final isSelected = index == _selectedChapter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AnimatedScaleButton(
                      onTap: () => setState(() => _selectedChapter = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? GameConfig.secondary : Colors.white,
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
                          children: [
                            Text(
                              GameConfig.chapterNames[index].toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : GameConfig.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (index > 0) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.lock_rounded,
                                size: 12,
                                color: isSelected ? Colors.white : GameConfig.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // Main Level Grid Card (5x4)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          final levelId = (_selectedChapter * 50) + index + 1;
                          final isUnlocked = userData.isLevelUnlocked(levelId);
                          final stars = userData.starRatings[levelId] ?? 0;
                          final isCurrent = levelId == userData.currentProgress + 1;

                          if (!isUnlocked) {
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F5F2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$levelId',
                                    style: TextStyle(
                                      color: GameConfig.textSecondary.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(Icons.lock_rounded, size: 16, color: GameConfig.textMuted),
                                ],
                              ),
                            );
                          }

                          return AnimatedScaleButton(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.gameplay,
                                arguments: levelId,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? GameConfig.secondary
                                    : (stars > 0 ? GameConfig.secondary : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isCurrent || stars > 0)
                                        ? GameConfig.secondaryDepth.withValues(alpha: 0.4)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: isCurrent
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$levelId',
                                    style: TextStyle(
                                      color: (isCurrent || stars > 0)
                                          ? Colors.white
                                          : GameConfig.textPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (stars > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(3, (s) {
                                        return Icon(
                                          s < stars
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          size: 10,
                                          color: GameConfig.accent,
                                        );
                                      }),
                                    )
                                  else if (isCurrent)
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (dot) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: dot == 0 ? 8 : 6,
                          height: dot == 0 ? 8 : 6,
                          decoration: BoxDecoration(
                            color: dot == 0 ? GameConfig.primary : GameConfig.textMuted,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // AdMob Banner
            if (GameConfig.showBannerOnLevelSelect)
              AdService.instance.getBannerWidget(),
          ],
        ),
      ),
    );
  }
}
