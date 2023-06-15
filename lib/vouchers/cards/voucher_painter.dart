import 'package:flutter/material.dart';
import 'package:local/theme/wl_colors.dart';

class VoucherPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 2.0;
    double circleRadius = 20;
    double cornerRadius = 8;
    double dashedLineWidth = 50;

    // Paint for the border of voucher
    var borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const goldDark = Color.fromRGBO(209, 174, 24, 1);
    const goldBright = Color.fromRGBO(255, 249, 133, 1);

    var leftFillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [goldDark, goldBright],
        stops: [0.1, 0.6],
      ).createShader(Rect.fromLTWH(0, 0, dashedLineWidth, size.height))
      ..style = PaintingStyle.fill;

    // Paint for the fill of right side of voucher
    var rightFillPaint = Paint()
      ..color = WlColors.primary.withOpacity(0.0)
      ..style = PaintingStyle.fill;

    // Paint for the dashed line
    var dashedLinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Create the main voucher shape
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    Path mainPath = Path()..addRRect(rRect);

    // Create cutouts at the middle of the left and right edges
    double centerY = size.height / 2;

    // Create a circle at the middle of the left edge
    Path leftCircle = Path()
      ..addOval(
          Rect.fromCircle(center: Offset(0, centerY), radius: circleRadius));

    // Create a circle at the middle of the right edge
    Path rightCircle = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width, centerY), radius: circleRadius));

    // Subtract the circles from the main path to create cutouts
    mainPath = Path.combine(PathOperation.difference, mainPath, leftCircle);
    mainPath = Path.combine(PathOperation.difference, mainPath, rightCircle);

    // Create a filled path for the left side of the voucher
    Path leftFillPath = Path.combine(PathOperation.intersect, mainPath,
        Path()..addRect(Rect.fromLTWH(0, 0, dashedLineWidth, size.height)));

    // Create a filled path for the right side of the voucher
    Path rightFillPath = Path.combine(
        PathOperation.intersect,
        mainPath,
        Path()
          ..addRect(Rect.fromLTWH(
              dashedLineWidth, 0, size.width - dashedLineWidth, size.height)));

    // Draw the filled left side of the voucher
    canvas.drawPath(leftFillPath, leftFillPaint);

    // Draw the filled right side of the voucher
    canvas.drawPath(rightFillPath, rightFillPaint);

    // Draw the voucher shape
    canvas.drawPath(mainPath, borderPaint);

    // Draw a vertical dashed line close to the left edge
    for (int i = 0; i < size.height.toInt(); i += 10) {
      if (i % 20 == 0) {
        canvas.drawLine(
          Offset(dashedLineWidth, i.toDouble()),
          Offset(dashedLineWidth, i.toDouble() + 10),
          dashedLinePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
