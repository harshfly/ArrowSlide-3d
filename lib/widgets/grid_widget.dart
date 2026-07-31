import 'package:flutter/material.dart';


/// Clean dark grid painter for ArrowSlide 3D.
class GridWidget extends StatelessWidget {
  final int gridWidth;
  final int gridHeight;
  final double cellSize;

  const GridWidget({
    super.key,
    required this.gridWidth,
    required this.gridHeight,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(gridWidth * cellSize, gridHeight * cellSize),
      painter: _GridPainter(gridWidth: gridWidth, gridHeight: gridHeight, cellSize: cellSize),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final double cellSize;

  _GridPainter({required this.gridWidth, required this.gridHeight, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final cellFill = Paint()
      ..color = const Color(0xFF182236)
      ..style = PaintingStyle.fill;

    final cellBorder = Paint()
      ..color = const Color(0xFF2C384E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
          const Radius.circular(8),
        );
        canvas.drawRRect(rect, cellFill);
        canvas.drawRRect(rect, cellBorder);
      }
    }

    // Outer thick grid border
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, gridWidth * cellSize, gridHeight * cellSize),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      outerRect,
      Paint()
        ..color = const Color(0xFF2C384E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.gridWidth != gridWidth || old.gridHeight != gridHeight || old.cellSize != cellSize;
}
