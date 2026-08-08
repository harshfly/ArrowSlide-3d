import 'package:flutter/material.dart';
import '../config.dart';

/// Heads-up display — level info, move count, par, undo, pause, restart.
///
/// All child widgets use const constructors where possible.
class HudWidget extends StatelessWidget {
  final int levelId;
  final int moveCount;
  final int parMoves;
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onPause;
  final VoidCallback onRestart;

  const HudWidget({
    super.key,
    required this.levelId,
    required this.moveCount,
    required this.parMoves,
    required this.canUndo,
    required this.onUndo,
    required this.onPause,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GameConfig.spacingMd,
        vertical: GameConfig.spacingSm,
      ),
      decoration: const BoxDecoration(
        color: GameConfig.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(GameConfig.radiusMd),
          bottomRight: Radius.circular(GameConfig.radiusMd),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Pause
            _HudIconButton(
              icon: Icons.pause_rounded,
              onTap: onPause,
              enabled: true,
            ),
            const SizedBox(width: GameConfig.spacingSm),

            // Level label
            Text(
              'LEVEL $levelId',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),

            const Spacer(),

            // Move counter
            DecoratedBox(
              decoration: BoxDecoration(
                color: GameConfig.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(GameConfig.radiusSm),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$moveCount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: moveCount <= parMoves
                            ? GameConfig.success
                            : GameConfig.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ' / $parMoves',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: GameConfig.spacingSm),
            _HudIconButton(
              icon: Icons.undo_rounded,
              onTap: onUndo,
              enabled: canUndo,
            ),
            const SizedBox(width: GameConfig.spacingXs),
            _HudIconButton(
              icon: Icons.refresh_rounded,
              onTap: onRestart,
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small icon button for the HUD — extracted for reuse.
class _HudIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _HudIconButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: GameConfig.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(GameConfig.radiusSm),
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? GameConfig.textColor
                : GameConfig.secondary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
