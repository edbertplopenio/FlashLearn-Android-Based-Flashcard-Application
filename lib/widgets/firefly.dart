import 'dart:math';
import 'package:flutter/material.dart';

class Firefly extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color color;

  const Firefly({
    Key? key,
    required this.size,
    required this.duration,
    required this.color,
  }) : super(key: key);

  @override
  _FireflyState createState() => _FireflyState();
}

class _FireflyState extends State<Firefly> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _dx, _dy;
  late double _glow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _dx = Random().nextDouble();
    _dy = Random().nextDouble();
    _glow = Random().nextDouble() * 0.5 + 0.5;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final dx = _dx + (_animation.value * 0.1) - 0.05;
        final dy = _dy + (_animation.value * 0.1) - 0.05;
        final glow = _glow + (_animation.value * 0.5);

        return Positioned(
          left: dx * MediaQuery.of(context).size.width,
          top: dy * MediaQuery.of(context).size.height,
          child: CustomPaint(
            painter: FireflyPainter(
              size: widget.size,
              glow: glow,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

class FireflyPainter extends CustomPainter {
  final double size;
  final double glow;
  final Color color;

  FireflyPainter({
    required this.size,
    required this.glow,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, this.size * glow * 3);

    canvas.drawCircle(Offset.zero, this.size * glow * 3, paint);

    paint
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, this.size * 1.5);

    canvas.drawCircle(Offset.zero, this.size * 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
