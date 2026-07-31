import 'package:flutter/material.dart';
import '../config.dart';

class DottedBackgroundPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double radius;

  DottedBackgroundPainter({
    required this.dotColor,
    this.spacing = 24.0,
    this.radius = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DottedBackground extends StatelessWidget {
  final Widget child;

  const DottedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DottedBackgroundPainter(
                dotColor: GameConfig.dottedGrid,
                spacing: 24.0,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
