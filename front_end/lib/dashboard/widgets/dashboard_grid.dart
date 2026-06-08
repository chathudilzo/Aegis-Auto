import 'package:flutter/material.dart';

class DashboardGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    final int horizontalLines = 4;
    for (int i = 1; i <= horizontalLines; i++) {
      double y = size.height * (i / (horizontalLines + 1));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final int verticalLines = 8;
    for (int i = 1; i <= verticalLines; i++) {
      double x = size.width * (i / (verticalLines + 1));
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
