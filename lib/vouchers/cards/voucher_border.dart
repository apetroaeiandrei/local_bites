import 'package:flutter/material.dart';
import 'package:local/theme/dimens.dart';
import 'package:local/theme/wl_colors.dart';

class VoucherBorder extends ShapeBorder {
  final double strokeWidth;
  final double circleRadius;
  final Paint dashedLinePaint;

  VoucherBorder({
    this.strokeWidth = 2,
    this.circleRadius = 14.0,
  })  : dashedLinePaint = Paint()
          ..color = WlColors.secondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
        super();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(strokeWidth);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _getVoucherPath(rect);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _getVoucherPath(rect);
  }

  Path _getVoucherPath(Rect rect) {
    // Create the main voucher shape
    Path mainPath = Path()..addRect(rect);

    // Create cutouts
    Path cutoutPath = Path()
      ..addOval(Rect.fromCircle(
          center: const Offset(0, 0), radius: circleRadius)) // top left
      ..addOval(Rect.fromCircle(
          center: Offset(rect.width, 0), radius: circleRadius)) // top right
      ..addOval(Rect.fromCircle(
          center: Offset(0, rect.height), radius: circleRadius)) // bottom left
      ..addOval(Rect.fromCircle(
          center: Offset(rect.width, rect.height),
          radius: circleRadius)) // bottom right
      ..addOval(Rect.fromCircle(
          center: Offset(_getDashedLineWidth(rect.size), 0),
          radius: circleRadius)) // above dashed line
      ..addOval(Rect.fromCircle(
          center: Offset(_getDashedLineWidth(rect.size), rect.height),
          radius: circleRadius)); // below dashed line

    // Subtract the cutouts from the main path
    mainPath = Path.combine(PathOperation.difference, mainPath, cutoutPath);

    return mainPath;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    double dashLength = circleRadius / 3;
    double dashGap = circleRadius / 3;

    for (double i = circleRadius;
        i < rect.height - circleRadius;
        i += dashLength + dashGap) {
      // Draw a dash
      canvas.drawLine(
        Offset(_getDashedLineWidth(rect.size), i),
        Offset(_getDashedLineWidth(rect.size), i + dashLength),
        dashedLinePaint,
      );
    }
  }

  double _getDashedLineWidth(Size size) {
    return size.width /
        ((Dimens.voucherDashLeftFlex + Dimens.voucherDashRightFlex) /
            Dimens.voucherDashLeftFlex);
  }

  @override
  ShapeBorder scale(double t) => this;
}
