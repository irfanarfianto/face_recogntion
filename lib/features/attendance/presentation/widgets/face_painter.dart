import 'package:flutter/material.dart';

class FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Define the Overlay Color
    final paint = Paint()
      ..color = Colors.black.withValues(alpha:0.5)
      ..style = PaintingStyle.fill;

    // 2. Define Dimensions
    final width = size.width * 0.8;
    final height = size.height * 0.5;
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2;
    final ovalRect = Rect.fromLTWH(left, top, width, height);

    // 3. Create a Path for the hole (The Face Oval)
    final ovalPath = Path()..addOval(ovalRect);

    // 4. Create a Path for the entire screen
    final paramsPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 5. Create the "Cutout" Path (Screen - Oval)
    final cutoutPath = Path.combine(
      PathOperation.difference,
      paramsPath,
      ovalPath,
    );

    // 6. Draw the Mask (Everything *outside* the oval gets dimmed)
    canvas.drawPath(cutoutPath, paint);

    // 7. Draw the White Border around the oval
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
