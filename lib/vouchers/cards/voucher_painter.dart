import 'package:flutter/material.dart';
import 'package:local/theme/wl_colors.dart';

import '../../theme/dimens.dart';

class VoucherPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 2.0;
    double circleRadius = 14;
    double dashedLineWidth = size.width /
        ((Dimens.voucherDashLeftFlex + Dimens.voucherDashRightFlex) /
            Dimens.voucherDashLeftFlex);

    // Paint for the border of voucher
    var borderPaint = Paint()
      ..color = WlColors.goldContrast
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    var fillPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.topRight,
        colors: [WlColors.goldBright, WlColors.goldDark],
        tileMode: TileMode.mirror,
        radius: 1.0,
        stops: [0.1, 0.9],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Paint for the dashed line
    var dashedLinePaint = Paint()
      ..color = WlColors.goldContrast
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Create the main voucher shape
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    Path mainPath = Path()..addRect(rect);

    // Create cutouts
    Path cutoutPath = Path()
      ..addOval(Rect.fromCircle(
          center: const Offset(0, 0), radius: circleRadius)) // top left
      ..addOval(Rect.fromCircle(
          center: Offset(size.width, 0), radius: circleRadius)) // top right
      ..addOval(Rect.fromCircle(
          center: Offset(0, size.height), radius: circleRadius)) // bottom left
      ..addOval(Rect.fromCircle(
          center: Offset(size.width, size.height),
          radius: circleRadius)) // bottom right
      ..addOval(Rect.fromCircle(
          center: Offset(dashedLineWidth, 0),
          radius: circleRadius)) // above dashed line
      ..addOval(Rect.fromCircle(
          center: Offset(dashedLineWidth, size.height),
          radius: circleRadius)); // below dashed line

    // Subtract the cutouts from the main path
    mainPath = Path.combine(PathOperation.difference, mainPath, cutoutPath);

    // Draw the filled voucher
    canvas.drawPath(mainPath, fillPaint);

    // Draw the voucher border
    canvas.drawPath(mainPath, borderPaint);

    // Calculate the length and gap of the dashes based on the circle radius
    double dashLength = circleRadius / 3;
    double dashGap = circleRadius / 3;

// Start drawing the dashed line from the bottom of the top cutout and stop at the top of the bottom cutout
    for (double i = circleRadius;
        i < size.height - circleRadius;
        i += dashLength + dashGap) {
      // Draw a dash
      canvas.drawLine(
        Offset(dashedLineWidth, i),
        Offset(dashedLineWidth, i + dashLength),
        dashedLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
