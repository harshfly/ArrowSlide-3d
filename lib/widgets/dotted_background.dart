import 'package:flutter/material.dart';
import '../config.dart';

/// Dotted background pattern painter.
///
/// Uses [shouldRepaint] → false to avoid unnecessary repaints.
/// The background is wrapped in a [RepaintBoundary] for isolation.
class DottedBackgroundPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double radius;

  const DottedBackgroundPainter({
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
  bool shouldRepaint(covariant DottedBackgroundPainter oldDelegate) =>
      dotColor != oldDelegate.dotColor ||
      spacing != oldDelegate.spacing ||
      radius != oldDelegate.radius;
}

/// Provides a dotted background pattern behind [child].
///
/// Does NOT wrap in a Scaffold — callers are responsible for their own Scaffold.
/// This avoids the double-Scaffold bug that causes rendering overhead.
class DottedBackground extends StatelessWidget {
  final Widget child;

  const DottedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: DottedBackgroundPainter(
                dotColor: GameConfig.dottedGrid,
                spacing: 24.0,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
