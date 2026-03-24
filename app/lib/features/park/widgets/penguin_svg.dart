import 'package:flutter/material.dart';

class PenguinSvg extends StatelessWidget {
  final Color color;
  final String accessory;
  final double size;

  const PenguinSvg({
    super.key,
    this.color = const Color(0xFF4A4A6A),
    this.accessory = 'none',
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: _PenguinPainter(color: color, accessory: accessory),
    );
  }
}

class _PenguinPainter extends CustomPainter {
  final Color color;
  final String accessory;

  _PenguinPainter({required this.color, required this.accessory});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final scale = size.width / 60;

    canvas.save();
    canvas.scale(scale, scale);

    // Wings
    paint.color = color;
    canvas.save();
    canvas.translate(10, 42);
    canvas.rotate(-0.35);
    canvas.drawOval(const Rect.fromLTWH(-8, -13, 16, 26), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(50, 42);
    canvas.rotate(0.35);
    canvas.drawOval(const Rect.fromLTWH(-8, -13, 16, 26), paint);
    canvas.restore();

    // Body
    canvas.drawOval(const Rect.fromLTWH(12, 26, 36, 40), paint);

    // Belly
    paint.color = const Color(0xFFF5F5F5);
    canvas.drawOval(const Rect.fromLTWH(19, 36, 22, 28), paint);

    // Head
    paint.color = color;
    canvas.drawCircle(const Offset(30, 21), 16, paint);

    // Eye whites
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(23.5, 18), 5, paint);
    canvas.drawCircle(const Offset(36.5, 18), 5, paint);

    // Pupils
    paint.color = const Color(0xFF1A1A2E);
    canvas.drawCircle(const Offset(24.5, 19), 3, paint);
    canvas.drawCircle(const Offset(37.5, 19), 3, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(25.5, 18), 1, paint);
    canvas.drawCircle(const Offset(38.5, 18), 1, paint);

    // Beak
    paint.color = const Color(0xFFF0A020);
    final beakPath = Path()
      ..moveTo(27, 24)
      ..lineTo(30, 30)
      ..lineTo(33, 24)
      ..close();
    canvas.drawPath(beakPath, paint);

    // Blush
    paint.color = const Color(0xFFFFB3C6).withValues(alpha: 0.5);
    canvas.drawOval(const Rect.fromLTWH(16, 20.5, 8, 5), paint);
    canvas.drawOval(const Rect.fromLTWH(36, 20.5, 8, 5), paint);

    // Feet
    paint.color = const Color(0xFFF0A020);
    canvas.drawOval(const Rect.fromLTWH(17, 62, 14, 6), paint);
    canvas.drawOval(const Rect.fromLTWH(29, 62, 14, 6), paint);

    // Accessories
    _drawAccessory(canvas, paint);

    canvas.restore();
  }

  void _drawAccessory(Canvas canvas, Paint paint) {
    switch (accessory) {
      case 'tie':
        paint.color = const Color(0xFFC0392B);
        canvas.drawRect(const Rect.fromLTWH(27.5, 30, 5, 3), paint);
        final tiePath = Path()
          ..moveTo(27, 33)
          ..lineTo(30, 44)
          ..lineTo(33, 33)
          ..close();
        canvas.drawPath(tiePath, paint);
        break;
      case 'glasses':
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        paint.color = const Color(0xFF4A3728);
        canvas.drawCircle(const Offset(23.5, 18), 6, paint);
        canvas.drawCircle(const Offset(36.5, 18), 6, paint);
        canvas.drawLine(const Offset(29.5, 18), const Offset(30.5, 18), paint);
        canvas.drawLine(const Offset(5, 18), const Offset(17.5, 18), paint);
        canvas.drawLine(const Offset(42.5, 18), const Offset(55, 18), paint);
        break;
      case 'bow':
        paint.style = PaintingStyle.fill;
        paint.color = const Color(0xFFFF69B4);
        final bowPath = Path()
          ..moveTo(25, 6)
          ..lineTo(30, 12)
          ..lineTo(25, 18)
          ..close();
        canvas.drawPath(bowPath, paint);
        final bowPath2 = Path()
          ..moveTo(35, 6)
          ..lineTo(30, 12)
          ..lineTo(35, 18)
          ..close();
        canvas.drawPath(bowPath2, paint);
        paint.color = const Color(0xFFFF1493);
        canvas.drawCircle(const Offset(30, 12), 3.5, paint);
        break;
      case 'hardhat':
        paint.color = const Color(0xFFFF9500);
        canvas.drawOval(const Rect.fromLTWH(16, 0, 28, 16), paint);
        canvas.drawRect(const Rect.fromLTWH(15, 13, 30, 4), paint);
        break;
      case 'crown':
        paint.color = const Color(0xFFFFD700);
        final crownPath = Path()
          ..moveTo(18, 12)
          ..lineTo(22, 5)
          ..lineTo(30, 10)
          ..lineTo(38, 5)
          ..lineTo(42, 12)
          ..close();
        canvas.drawPath(crownPath, paint);
        canvas.drawRect(const Rect.fromLTWH(18, 12, 24, 5), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PenguinPainter oldDelegate) {
    return color != oldDelegate.color || accessory != oldDelegate.accessory;
  }
}
