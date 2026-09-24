import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/anime_theme.dart';

class AnimeLogoCrest extends StatelessWidget {
  final double size;
  final bool animate;

  const AnimeLogoCrest({
    super.key,
    this.size = 120,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing pulsing ring
          Container(
            width: size * 0.95,
            height: size * 0.95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AnimeColors.sakuraPink.withAlpha(60),
                  AnimeColors.animeViolet.withAlpha(20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Rotating magical crest painter
          CustomPaint(
            size: Size(size, size),
            painter: _AnimeCrestPainter(),
          ),
        ],
      ),
    );
  }
}

class _AnimeCrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Glowing outer circle
    final glowPaint = Paint()
      ..shader = AnimeColors.sakuraGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, glowPaint);

    // Inner subtle ring
    final innerPaint = Paint()
      ..color = AnimeColors.starlightGold.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.78, innerPaint);

    // 5 Sakura Petals radiating from center
    const petals = 5;
    final petalPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AnimeColors.sakuraPink, AnimeColors.flameCrimson],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.75))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi / petals) - (math.pi / 2);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final petalPath = Path();
      final pw = radius * 0.38;
      final ph = radius * 0.65;

      petalPath.moveTo(0, 0);
      petalPath.cubicTo(pw, -ph * 0.4, pw, -ph * 0.8, 0, -ph);
      petalPath.cubicTo(-pw, -ph * 0.8, -pw, -ph * 0.4, 0, 0);
      petalPath.close();

      canvas.drawPath(petalPath, petalPaint);

      // Gold center star dot
      final goldStarPaint = Paint()..color = AnimeColors.starlightGold;
      canvas.drawCircle(Offset(0, -ph * 0.75), 2.2, goldStarPaint);

      canvas.restore();
    }

    // Central glowing core
    final centerCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.22, centerCorePaint);

    final centerStarPaint = Paint()
      ..color = AnimeColors.starlightGold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.12, centerStarPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimeChibiMascot extends StatelessWidget {
  final double size;
  final String mood; // 'happy', 'quest', 'sleeping'

  const AnimeChibiMascot({
    super.key,
    this.size = 140,
    this.mood = 'happy',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AnimeChibiCatPainter(mood: mood),
      ),
    );
  }
}

class _AnimeChibiCatPainter extends CustomPainter {
  final String mood;

  _AnimeChibiCatPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;
    final headRadius = size.width * 0.35;

    // Head Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + headRadius * 0.9),
        width: headRadius * 2.1,
        height: headRadius * 0.5,
      ),
      shadowPaint,
    );

    // Ears
    final earPaint = Paint()..color = const Color(0xFFFFD1DC);
    final earInnerPaint = Paint()..color = const Color(0xFFFF85A1);

    // Left Ear
    final leftEar = Path()
      ..moveTo(cx - headRadius * 0.8, cy - headRadius * 0.4)
      ..lineTo(cx - headRadius * 0.9, cy - headRadius * 1.15)
      ..lineTo(cx - headRadius * 0.2, cy - headRadius * 0.8)
      ..close();
    canvas.drawPath(leftEar, earPaint);

    final leftEarInner = Path()
      ..moveTo(cx - headRadius * 0.75, cy - headRadius * 0.5)
      ..lineTo(cx - headRadius * 0.82, cy - headRadius * 1.0)
      ..lineTo(cx - headRadius * 0.3, cy - headRadius * 0.75)
      ..close();
    canvas.drawPath(leftEarInner, earInnerPaint);

    // Right Ear
    final rightEar = Path()
      ..moveTo(cx + headRadius * 0.8, cy - headRadius * 0.4)
      ..lineTo(cx + headRadius * 0.9, cy - headRadius * 1.15)
      ..lineTo(cx + headRadius * 0.2, cy - headRadius * 0.8)
      ..close();
    canvas.drawPath(rightEar, earPaint);

    final rightEarInner = Path()
      ..moveTo(cx + headRadius * 0.75, cy - headRadius * 0.5)
      ..lineTo(cx + headRadius * 0.82, cy - headRadius * 1.0)
      ..lineTo(cx + headRadius * 0.3, cy - headRadius * 0.75)
      ..close();
    canvas.drawPath(rightEarInner, earInnerPaint);

    // Head (cute round anime face)
    final facePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), headRadius, facePaint);

    // Head outline
    final faceBorder = Paint()
      ..color = const Color(0xFFFFB3C6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(cx, cy), headRadius, faceBorder);

    // Cute Cheeks (Blush)
    final blushPaint = Paint()..color = const Color(0xFFFF7597).withAlpha(120);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - headRadius * 0.55, cy + headRadius * 0.2),
        width: headRadius * 0.35,
        height: headRadius * 0.22,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + headRadius * 0.55, cy + headRadius * 0.2),
        width: headRadius * 0.35,
        height: headRadius * 0.22,
      ),
      blushPaint,
    );

    // Anime Eyes
    if (mood == 'sleeping') {
      final sleepEye = Paint()
        ..color = const Color(0xFF4A3E56)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      // Arc eyes ^  ^
      final leftArc = Path()
        ..moveTo(cx - headRadius * 0.45, cy + headRadius * 0.05)
        ..quadraticBezierTo(
          cx - headRadius * 0.32,
          cy - headRadius * 0.15,
          cx - headRadius * 0.18,
          cy + headRadius * 0.05,
        );
      canvas.drawPath(leftArc, sleepEye);

      final rightArc = Path()
        ..moveTo(cx + headRadius * 0.18, cy + headRadius * 0.05)
        ..quadraticBezierTo(
          cx + headRadius * 0.32,
          cy - headRadius * 0.15,
          cx + headRadius * 0.45,
          cy + headRadius * 0.05,
        );
      canvas.drawPath(rightArc, sleepEye);
    } else {
      // Big sparkling anime eyes
      final eyePaint = Paint()..color = const Color(0xFF2C2248);
      final leftEyeRect = Rect.fromCenter(
        center: Offset(cx - headRadius * 0.32, cy - headRadius * 0.05),
        width: headRadius * 0.28,
        height: headRadius * 0.38,
      );
      final rightEyeRect = Rect.fromCenter(
        center: Offset(cx + headRadius * 0.32, cy - headRadius * 0.05),
        width: headRadius * 0.28,
        height: headRadius * 0.38,
      );
      canvas.drawOval(leftEyeRect, eyePaint);
      canvas.drawOval(rightEyeRect, eyePaint);

      // Eye reflections (Anime Highlights)
      final highlightPaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(cx - headRadius * 0.35, cy - headRadius * 0.15),
        headRadius * 0.08,
        highlightPaint,
      );
      canvas.drawCircle(
        Offset(cx - headRadius * 0.25, cy + headRadius * 0.02),
        headRadius * 0.04,
        highlightPaint,
      );

      canvas.drawCircle(
        Offset(cx + headRadius * 0.29, cy - headRadius * 0.15),
        headRadius * 0.08,
        highlightPaint,
      );
      canvas.drawCircle(
        Offset(cx + headRadius * 0.39, cy + headRadius * 0.02),
        headRadius * 0.04,
        highlightPaint,
      );
    }

    // Tiny Triangle Nose
    final nosePaint = Paint()..color = const Color(0xFFFF5E86);
    final nose = Path()
      ..moveTo(cx, cy + headRadius * 0.12)
      ..lineTo(cx - 3.5, cy + headRadius * 0.07)
      ..lineTo(cx + 3.5, cy + headRadius * 0.07)
      ..close();
    canvas.drawPath(nose, nosePaint);

    // Mouth :3
    final mouthPaint = Paint()
      ..color = const Color(0xFF5A496A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final mouth = Path()
      ..moveTo(cx - 8, cy + headRadius * 0.2)
      ..quadraticBezierTo(cx - 4, cy + headRadius * 0.27, cx, cy + headRadius * 0.2)
      ..quadraticBezierTo(cx + 4, cy + headRadius * 0.27, cx + 8, cy + headRadius * 0.2);
    canvas.drawPath(mouth, mouthPaint);

    // Sakura flower on forehead / hair clip
    final flowerPaint = Paint()..color = const Color(0xFFFF5E86);
    final flowerCenter = Offset(cx + headRadius * 0.6, cy - headRadius * 0.6);
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      final fx = flowerCenter.dx + math.cos(a) * 7;
      final fy = flowerCenter.dy + math.sin(a) * 7;
      canvas.drawCircle(Offset(fx, fy), 4.5, flowerPaint);
    }
    canvas.drawCircle(flowerCenter, 3.5, Paint()..color = AnimeColors.starlightGold);
  }

  @override
  bool shouldRepaint(covariant _AnimeChibiCatPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
