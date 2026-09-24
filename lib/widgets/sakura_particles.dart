import 'dart:math' as math;
import 'package:flutter/material.dart';

class SakuraPetalsOverlay extends StatefulWidget {
  final int petalCount;
  final Widget? child;
  final bool isEnabled;

  const SakuraPetalsOverlay({
    super.key,
    this.petalCount = 18,
    this.child,
    this.isEnabled = true,
  });

  @override
  State<SakuraPetalsOverlay> createState() => _SakuraPetalsOverlayState();
}

class _SakuraPetalsOverlayState extends State<SakuraPetalsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Petal> _petals;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _petals = List.generate(widget.petalCount, (index) => _createPetal(randomY: true));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        if (mounted && widget.isEnabled) {
          setState(() {
            for (var petal in _petals) {
              petal.update();
            }
          });
        }
      });

    if (widget.isEnabled) {
      _controller.repeat();
    }
  }

  _Petal _createPetal({bool randomY = false}) {
    return _Petal(
      x: _random.nextDouble(),
      y: randomY ? _random.nextDouble() : -0.1,
      size: 10.0 + _random.nextDouble() * 14.0,
      speedY: 0.0015 + _random.nextDouble() * 0.0025,
      speedX: (_random.nextDouble() - 0.5) * 0.0015,
      swayFreq: 1.0 + _random.nextDouble() * 2.0,
      swayOffset: _random.nextDouble() * math.pi * 2,
      rotation: _random.nextDouble() * math.pi * 2,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.04,
      opacity: 0.35 + _random.nextDouble() * 0.45,
    );
  }

  @override
  void didUpdateWidget(SakuraPetalsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (widget.isEnabled)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SakuraPainter(petals: _petals),
              ),
            ),
          ),
      ],
    );
  }
}

class _Petal {
  double x;
  double y;
  final double size;
  final double speedY;
  final double speedX;
  final double swayFreq;
  final double swayOffset;
  double rotation;
  final double rotationSpeed;
  final double opacity;
  double tick = 0;

  _Petal({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.swayFreq,
    required this.swayOffset,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
  });

  void update() {
    tick += 0.02;
    y += speedY;
    x += speedX + math.sin(tick * swayFreq + swayOffset) * 0.0015;
    rotation += rotationSpeed;

    // Reset when off bottom or edges
    if (y > 1.1) {
      y = -0.05;
      x = math.Random().nextDouble();
    }
    if (x < -0.1) x = 1.05;
    if (x > 1.1) x = -0.05;
  }
}

class _SakuraPainter extends CustomPainter {
  final List<_Petal> petals;

  _SakuraPainter({required this.petals});

  @override
  void paint(Canvas canvas, Size size) {
    for (final petal in petals) {
      final px = petal.x * size.width;
      final py = petal.y * size.height;

      final paint = Paint()
        ..color = const Color(0xFFFF85A1).withAlpha((petal.opacity * 255).round())
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(petal.rotation);

      // Draw cute sakura petal shape
      final path = Path();
      final w = petal.size;
      final h = petal.size * 1.5;

      path.moveTo(0, -h / 2);
      path.cubicTo(w / 2, -h / 3, w / 2, h / 3, 0, h / 2);
      path.cubicTo(-w / 2, h / 3, -w / 2, -h / 3, 0, -h / 2);
      path.close();

      // Center notch characteristic of cherry blossom petal
      final notchPath = Path();
      notchPath.moveTo(-w * 0.15, -h * 0.48);
      notchPath.lineTo(0, -h * 0.38);
      notchPath.lineTo(w * 0.15, -h * 0.48);

      canvas.drawPath(path, paint);

      // Subtle inner petal vein
      final veinPaint = Paint()
        ..color = const Color(0xFFFFB3C6).withAlpha((petal.opacity * 200).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(0, -h * 0.3), Offset(0, h * 0.3), veinPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SakuraPainter oldDelegate) => true;
}
