import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/arrow_block.dart';

/// Precomputed color palette for arrow blocks.
/// Cached by block ID hash to avoid per-frame allocations.
class _BlockColors {
  final List<Color> topGradient;
  final Color sideColor;

  const _BlockColors(this.topGradient, this.sideColor);

  static const _palettes = <List<Color>>[
    [Color(0xFFFF6B70), Color(0xFFFF4D53)], // Red/Coral
    [Color(0xFF5CA4FF), Color(0xFF3388FF)], // Blue
    [Color(0xFF4EE1A8), Color(0xFF26CA88)], // Green
    [Color(0xFFFFC53D), Color(0xFFFAAD14)], // Yellow
    [Color(0xFFC068FF), Color(0xFFA13DFF)], // Purple
    [Color(0xFFFF9A4D), Color(0xFFFF7A1E)], // Orange
  ];

  static const _sideColors = <Color>[
    Color(0xFFD93D43), // Red Side
    Color(0xFF216DE6), // Blue Side
    Color(0xFF19B273), // Green Side
    Color(0xFFD8920C), // Yellow Side
    Color(0xFF8622E3), // Purple Side
    Color(0xFFDB600A), // Orange Side
  ];

  static final _cache = <int, _BlockColors>{};

  static _BlockColors forId(String id) {
    final hash = id.hashCode.abs();
    return _cache.putIfAbsent(hash, () {
      final index = hash % _palettes.length;
      return _BlockColors(_palettes[index], _sideColors[index]);
    });
  }
}

/// Renders a single arrow block as a glossy 3D isometric rounded clay cube.
///
/// Production optimizations:
/// - Precomputed & cached color palettes per block ID
/// - Const paint objects reused across frames
/// - RepaintBoundary should be applied by the parent
class ArrowBlockWidget extends StatelessWidget {
  final ArrowBlock block;
  final double cellSize;
  final VoidCallback? onTap;
  final VoidCallback? onSwipe;
  final bool isAnimating;
  final bool isHighlighted;

  const ArrowBlockWidget({
    super.key,
    required this.block,
    required this.cellSize,
    this.onTap,
    this.onSwipe,
    this.isAnimating = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final blockSize = cellSize * 0.85;
    const depthY = 8.0;

    if (block.isHidden) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final colors = _BlockColors.forId(block.id);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cellSize,
        height: cellSize,
        child: Center(
          child: SizedBox(
            width: blockSize,
            height: blockSize + depthY,
            child: Stack(
              children: [
                // Soft Drop Shadow
                Positioned(
                  top: depthY + 3,
                  left: 2,
                  right: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x29000000), // 0.16 alpha
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SizedBox(height: blockSize),
                  ),
                ),

                // Depth Layer (Darker Side Color)
                Positioned(
                  top: depthY,
                  left: 0,
                  right: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.sideColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: SizedBox(height: blockSize),
                  ),
                ),

                // Main Face Layer (Gradient Clay Top)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: blockSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors.topGradient,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: isHighlighted
                          ? Border.all(color: Colors.white, width: 3.5)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Clay top inner sheen highlight
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.28),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                            child: SizedBox(height: blockSize * 0.42),
                          ),
                        ),
                        // Arrow Icon
                        Center(
                          child: _ArrowIcon(
                            direction: block.direction,
                            size: blockSize * 0.52,
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
      ),
    );
  }
}

/// Lightweight arrow icon widget using CustomPaint.
class _ArrowIcon extends StatelessWidget {
  final Direction direction;
  final double size;

  const _ArrowIcon({required this.direction, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ThickArrowPainter(
          direction: direction,
          color: const Color(0xFAFFFFFF), // 0.98 alpha white
        ),
      ),
    );
  }
}

class _ThickArrowPainter extends CustomPainter {
  final Direction direction;
  final Color color;

  const _ThickArrowPainter({required this.direction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);

    // Rotate based on direction (default is UP)
    switch (direction) {
      case Direction.up:
        break;
      case Direction.right:
        canvas.rotate(math.pi / 2);
      case Direction.down:
        canvas.rotate(math.pi);
      case Direction.left:
        canvas.rotate(-math.pi / 2);
    }

    canvas.translate(-cx, -cy);

    // Draw Up Arrow — stem + head
    path.moveTo(size.width / 2, size.height * 0.88);
    path.lineTo(size.width / 2, size.height * 0.12);
    path.moveTo(size.width * 0.18, size.height * 0.42);
    path.lineTo(size.width / 2, size.height * 0.12);
    path.lineTo(size.width * 0.82, size.height * 0.42);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThickArrowPainter oldDelegate) =>
      direction != oldDelegate.direction || color != oldDelegate.color;
}
