import 'dart:math' show pi, sin, cos;
import 'package:flutter/material.dart';
import 'card_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CardPatternPainter — subtle geometric patterns per card type
// ─────────────────────────────────────────────────────────────────────────────

class CardPatternPainter extends CustomPainter {
  final CardType type;
  final Color patternColor;

  const CardPatternPainter({
    required this.type,
    required this.patternColor,
  });

  // Hoisted paint — avoids one Paint allocation per paint() call.
  static final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _paint
      ..color = patternColor
      ..style = PaintingStyle.fill;

    switch (type) {
      case CardType.question:
        _paintWaves(canvas, size, paint);
        break;
      case CardType.dare:
        _paintDiagonalStreaks(canvas, size, paint);
        break;
      case CardType.vote:
        _paintDots(canvas, size, paint);
        break;
      case CardType.punishment:
        _paintWarningStripes(canvas, size, paint);
        break;
      case CardType.bonus:
        _paintSparkles(canvas, size, paint);
        break;
    }
  }

  // ── QUESTION: soft waves ─────────────────────────────────────────────────
  void _paintWaves(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final waveHeight = size.height * 0.15;
    final waveWidth = size.width * 0.4;

    // Wave 1 - top right
    path.moveTo(size.width * 0.6, 0);
    for (double x = size.width * 0.6; x <= size.width; x += 10) {
      final y = waveHeight * sin((x / waveWidth) * 2 * pi);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Wave 2 - bottom left
    final path2 = Path();
    path2.moveTo(0, size.height);
    for (double x = 0; x <= size.width * 0.4; x += 10) {
      final y = size.height - waveHeight * sin((x / waveWidth) * 2 * pi);
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width * 0.4, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  // ── DARE: diagonal energy streaks ───────────────────────────────────────
  void _paintDiagonalStreaks(Canvas canvas, Size size, Paint paint) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    // Streak 1 - top left to center
    canvas.drawLine(
      Offset(-size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.4, size.height * 0.5),
      paint,
    );

    // Streak 2 - top right to bottom
    canvas.drawLine(
      Offset(size.width * 0.7, -size.height * 0.05),
      Offset(size.width * 1.1, size.height * 0.6),
      paint,
    );

    // Streak 3 - bottom left
    canvas.drawLine(
      Offset(-size.width * 0.05, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 1.05),
      paint,
    );
  }

  // ── VOTE: dots grid ──────────────────────────────────────────────────────
  void _paintDots(Canvas canvas, Size size, Paint paint) {
    final dotRadius = size.width * 0.025;
    final spacing = size.width * 0.15;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  // ── PUNISHMENT: warning stripes (very subtle) ────────────────────────────
  void _paintWarningStripes(Canvas canvas, Size size, Paint paint) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    const stripeCount = 4;
    final spacing = size.width / stripeCount;

    for (int i = 0; i < stripeCount; i++) {
      final x = spacing * i + spacing / 2;
      canvas.drawLine(
        Offset(x - size.height * 0.3, -size.height * 0.1),
        Offset(x + size.height * 0.3, size.height * 1.1),
        paint,
      );
    }
  }

  // ── BONUS: sparkles ──────────────────────────────────────────────────────
  void _paintSparkles(Canvas canvas, Size size, Paint paint) {
    final sparkles = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.75, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.8),
    ];

    for (final center in sparkles) {
      _drawStar(canvas, center, size.width * 0.04, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 4;
    final outerRadius = radius;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CardPatternPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.patternColor != patternColor;
  }
}
