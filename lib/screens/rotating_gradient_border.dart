import 'package:flutter/material.dart';
import 'dart:math' as math;

class RotatingGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double glowRadius;
  final List<Color> colors;

  const RotatingGradientBorder({
    Key? key,
    required this.child,
    this.borderWidth = 2.0,
    this.glowRadius = 4.0,
    required this.colors,
  }) : super(key: key);

  @override
  _RotatingGradientBorderState createState() => _RotatingGradientBorderState();
}

class _RotatingGradientBorderState extends State<RotatingGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RotatingGradientBorderPainter(
            animation: _controller,
            borderWidth: widget.borderWidth,
            glowRadius: widget.glowRadius,
            colors: widget.colors,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: widget.colors.first.withOpacity(0.5),
                  blurRadius: widget.glowRadius,
                  spreadRadius: widget.glowRadius / 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _RotatingGradientBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final double borderWidth;
  final double glowRadius;
  final List<Color> colors;

  _RotatingGradientBorderPainter({
    required this.animation,
    required this.borderWidth,
    required this.glowRadius,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double rotation = animation.value * 2 * math.pi;

    final Gradient gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: colors,
      transform: GradientRotation(rotation),
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(12.0));

    canvas.drawRRect(rRect.inflate(borderWidth / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
