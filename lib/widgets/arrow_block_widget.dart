import 'package:flutter/material.dart';

import '../models/arrow_block.dart';

/// Renders a single arrow block as a glossy 3D isometric rounded clay cube.
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
    // Make the block size a bit smaller than the cell size so they aren't touching
    final blockSize = cellSize * 0.85;
    final depthY = 8.0;

    if (block.isHidden) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final topColors = _topGradientColors();
    final sideColor = _sideColor();
    final glowColor = Colors.black.withValues(alpha: 0.16); // soft drop shadow

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
                  child: Container(
                    height: blockSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor,
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),

                // Depth Layer (Darker Side Color)
                Positioned(
                  top: depthY,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: blockSize,
                    decoration: BoxDecoration(
                      color: sideColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
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
                        colors: topColors,
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
                          child: Container(
                            height: blockSize * 0.42,
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
                          ),
                        ),
                        // Arrow Icon
                        Center(
                          child: _buildArrowIcon(blockSize),
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

  Widget _buildArrowIcon(double size) {
    return SizedBox(
      width: size * 0.52,
      height: size * 0.52,
      child: CustomPaint(
        painter: _ThickArrowPainter(
          direction: block.direction,
          color: Colors.white.withValues(alpha: 0.98),
        ),
      ),
    );
  }

  List<Color> _topGradientColors() {
    final palettes = [
      // Vibrant Red/Coral
      [const Color(0xFFFF6B70), const Color(0xFFFF4D53)],
      // Crisp Blue
      [const Color(0xFF5CA4FF), const Color(0xFF3388FF)],
      // Minty Green
      [const Color(0xFF4EE1A8), const Color(0xFF26CA88)],
      // Sunny Yellow
      [const Color(0xFFFFC53D), const Color(0xFFFAAD14)],
      // Rich Purple
      [const Color(0xFFC068FF), const Color(0xFFA13DFF)],
      // Tangy Orange
      [const Color(0xFFFF9A4D), const Color(0xFFFF7A1E)],
    ];
    final hash = block.id.hashCode.abs();
    return palettes[hash % palettes.length];
  }

  Color _sideColor() {
    final colors = [
      const Color(0xFFD93D43), // Red Side
      const Color(0xFF216DE6), // Blue Side
      const Color(0xFF19B273), // Green Side
      const Color(0xFFD8920C), // Yellow Side
      const Color(0xFF8622E3), // Purple Side
      const Color(0xFFDB600A), // Orange Side
    ];
    final hash = block.id.hashCode.abs();
    return colors[hash % colors.length];
  }
}

class _ThickArrowPainter extends CustomPainter {
  final Direction direction;
  final Color color;

  _ThickArrowPainter({required this.direction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Rotate based on direction (assuming default is UP)
    switch (direction) {
      case Direction.up:
        break;
      case Direction.right:
        canvas.rotate(3.14159 / 2);
        break;
      case Direction.down:
        canvas.rotate(3.14159);
        break;
      case Direction.left:
        canvas.rotate(-3.14159 / 2);
        break;
    }

    canvas.translate(-center.dx, -center.dy);

    // Draw Up Arrow
    // Stem
    path.moveTo(size.width / 2, size.height * 0.88);
    path.lineTo(size.width / 2, size.height * 0.12);
    // Head
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
