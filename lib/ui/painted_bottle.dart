import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'brand_theme.dart';

/// Custom-painted, resolution-independent glass tube with four fluid bands.
class PaintedBottle extends StatelessWidget {
  const PaintedBottle({
    super.key,
    required this.layers,
    this.selected = false,
    this.height = 150,
  });
  final List<int> layers;
  final bool selected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.055 : 1,
      duration: const Duration(milliseconds: 160),
      child: SizedBox(
        width: height * .48,
        height: height,
        child: CustomPaint(
          painter: _BottlePainter(layers: layers, selected: selected),
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  _BottlePainter({required this.layers, required this.selected});
  final List<int> layers;
  final bool selected;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final left = w * .13, right = w * .87;
    final top = h * .06, bottom = h * .93;
    final bottle = RRect.fromRectAndCorners(
      Rect.fromLTRB(left, top, right, bottom),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
      bottomLeft: Radius.circular(w * .23),
      bottomRight: Radius.circular(w * .23),
    );
    final glass = Paint()..color = Colors.white.withValues(alpha: .10);
    canvas.drawRRect(bottle, glass);
    canvas.save();
    canvas.clipRRect(bottle);
    final innerLeft = left + 3, innerRight = right - 3;
    final fluidBottom = bottom - 3;
    final unitHeight = (fluidBottom - top - 5) / 4;
    for (var i = 0; i < layers.length && i < 4; i++) {
      final color = Brand.liquids[layers[i] % Brand.liquids.length];
      final band = Rect.fromLTRB(
        innerLeft,
        fluidBottom - unitHeight * (i + 1),
        innerRight,
        fluidBottom - unitHeight * i + 1,
      );
      canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.lerp(color, Colors.white, .20)!,
              color,
              Color.lerp(color, Colors.black, .12)!,
            ],
          ).createShader(band),
      );
      final shine = Paint()..color = Colors.white.withValues(alpha: .24);
      canvas.drawLine(
        Offset(innerLeft + 3, band.top + 4),
        Offset(innerRight - 6, band.top + 4),
        shine..strokeWidth = 1,
      );
      if (i % 2 == 0) {
        canvas.drawCircle(
          Offset(innerRight - 10, band.center.dy + 3),
          math.min(w * .025, 2.2),
          Paint()..color = Colors.white.withValues(alpha: .35),
        );
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 5, top + 5, 4, h * .65),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withValues(alpha: .23),
    );
    canvas.restore();
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 3.5 : 2.5
      ..color = selected ? Brand.aqua : Colors.white.withValues(alpha: .78);
    canvas.drawRRect(bottle, outline);
    canvas.drawLine(
      Offset(left + 3, top),
      Offset(right - 3, top),
      Paint()
        ..color = Brand.navy
        ..strokeWidth = 6,
    );
    canvas.drawLine(
      Offset(left + 5, top),
      Offset(right - 5, top),
      Paint()
        ..color = Colors.white.withValues(alpha: .70)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _BottlePainter oldDelegate) =>
      oldDelegate.selected != selected ||
      !listEquals(oldDelegate.layers, layers);
}
