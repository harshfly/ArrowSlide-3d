import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/audio_service.dart';

class ClayButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color color;
  final Color depthColor;
  final double height;
  final double width;
  final double borderRadius;
  final double depth;
  final EdgeInsetsGeometry padding;

  const ClayButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.color,
    required this.depthColor,
    this.height = 64,
    this.width = double.infinity,
    this.borderRadius = 22,
    this.depth = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    AudioService.instance.playTap();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final topOffset = _isPressed ? (widget.depth - 2.0) : 0.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height + widget.depth,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Solid 3D Depth Layer (Bottom clay block)
            Positioned(
              top: widget.depth,
              left: 0,
              right: 0,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.depthColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
              ),
            ),

            // 3. Top Action Layer (Pushes down on tap)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOutCubic,
              top: topOffset,
              left: 0,
              right: 0,
              child: Container(
                height: widget.height,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
