import 'package:flutter/material.dart';

import '../models/arrow_block.dart';

/// Renders a single arrow block as a glossy 3D isometric rounded cube exactly matching the provided UI.
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
    // Make the block size almost as large as cell size to pack them tightly
    final blockSize = cellSize * 0.95; 
    final depthY = 8.0;

    if (block.isHidden) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final topColor = _topGradientColor();
    final sideColor = _sideColor();
    final glowColor = Colors.black.withValues(alpha: 0.15); // soft drop shadow

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
                  top: depthY + 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: blockSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor,
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                // Main Face Layer (Solid Color)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: blockSize,
                    decoration: BoxDecoration(
                      color: topColor,
                      borderRadius: BorderRadius.circular(16),
                      border: isHighlighted
                          ? Border.all(color: Colors.white, width: 4)
                          : null,
                    ),
                    child: Center(
                      child: _buildArrowIcon(blockSize),
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
      width: size * 0.5,
      height: size * 0.5,
      child: CustomPaint(
        painter: _ThickArrowPainter(
          direction: block.direction,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }

  Color _topGradientColor() {
    final colors = [
      const Color(0xFFFF5A5F), // Red
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF22C55E), // Green
      const Color(0xFFFACC15), // Yellow
      const Color(0xFFA855F7), // Purple
      const Color(0xFFFB923C), // Orange
    ];
    final hash = block.id.hashCode.abs();
    return colors[hash % colors.length];
  }

  Color _sideColor() {
    final colors = [
      const Color(0xFFE23636), // Red Side
      const Color(0xFF2563EB), // Blue Side
      const Color(0xFF16A34A), // Green Side
      const Color(0xFFCA8A04), // Yellow Side
      const Color(0xFF9333EA), // Purple Side
      const Color(0xFFEA580C), // Orange Side
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
      ..strokeWidth = size.width * 0.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Rotate based on direction (assuming default is UP)
    switch (direction) {
      case Direction.up: break;
      case Direction.right: canvas.rotate(3.14159 / 2); break;
      case Direction.down: canvas.rotate(3.14159); break;
      case Direction.left: canvas.rotate(-3.14159 / 2); break;
    }
    
    canvas.translate(-center.dx, -center.dy);

    // Draw Up Arrow
    // Stem
    path.moveTo(size.width / 2, size.height * 0.9);
    path.lineTo(size.width / 2, size.height * 0.1);
    // Head
    path.moveTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width / 2, size.height * 0.1);
    path.lineTo(size.width * 0.8, size.height * 0.4);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThickArrowPainter oldDelegate) =>
      direction != oldDelegate.direction || color != oldDelegate.color;
}
