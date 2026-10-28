import 'dart:math' as math;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'brand_theme.dart';

/// A glossy glass bottle with animated liquid change and selection tilt.
class PaintedBottle extends StatefulWidget {
  const PaintedBottle({
    super.key,
    required this.layers,
    this.selected = false,
    this.height = 150,
    this.reducedMotion = false,
  });

  final List<int> layers;
  final bool selected;
  final double height;
  final bool reducedMotion;

  @override
  State<PaintedBottle> createState() => _PaintedBottleState();
}

class _PaintedBottleState extends State<PaintedBottle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fill;
  late List<int> _previous;

  @override
  void initState() {
    super.initState();
    _previous = List<int>.from(widget.layers);
    _fill = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant PaintedBottle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.layers, widget.layers)) {
      _previous = List<int>.from(oldWidget.layers);
      if (widget.reducedMotion) {
        _fill.value = 1;
      } else {
        _fill
          ..reset()
          ..forward();
      }
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: widget.selected && !widget.reducedMotion ? -.045 : 0,
      duration: const Duration(milliseconds: 210),
      child: AnimatedScale(
        scale: widget.selected && !widget.reducedMotion ? 1.055 : 1,
        duration: const Duration(milliseconds: 210),
        child: SizedBox(
          width: widget.height * .48,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _fill,
            builder: (_, _) => CustomPaint(
              painter: _GlassPainter(
                previous: _previous,
                current: widget.layers,
                progress: widget.reducedMotion
                    ? 1
                    : Curves.easeInOut.transform(_fill.value),
                selected: widget.selected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  const _GlassPainter({
    required this.previous,
    required this.current,
    required this.progress,
    required this.selected,
  });
  final List<int> previous;
  final List<int> current;
  final double progress;
  final bool selected;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final left = w * .13;
    final right = w * .87;
    final top = h * .07;
    final bottom = h * .93;
    final body = RRect.fromRectAndCorners(
      Rect.fromLTRB(left, top, right, bottom),
      topLeft: const Radius.circular(9),
      topRight: const Radius.circular(9),
      bottomLeft: Radius.circular(w * .26),
      bottomRight: Radius.circular(w * .26),
    );

    canvas.drawRRect(
      body,
      Paint()..color = Colors.white.withValues(alpha: .10),
    );
    canvas.save();
    canvas.clipRRect(body);
    _fluid(canvas, previous, 1 - progress, left, right, top, bottom, h);
    _fluid(canvas, current, progress, left, right, top, bottom, h);

    final glassReflection = Rect.fromLTWH(left + 5, top + 7, w * .08, h * .61);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glassReflection, const Radius.circular(5)),
      Paint()..color = Colors.white.withValues(alpha: .27),
    );
    canvas.restore();
    if (selected) {
      canvas.drawRRect(
        body.inflate(3),
        Paint()
          ..color = Brand.aqua.withValues(alpha: .42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 3.3 : 2.3
        ..color = selected ? Brand.aqua : Colors.white.withValues(alpha: .83),
    );
    // Tube rim and gleaming lip.
    canvas.drawLine(
      Offset(left + 4, top),
      Offset(right - 4, top),
      Paint()
        ..color = Brand.navy
        ..strokeWidth = 6,
    );
    canvas.drawLine(
      Offset(left + 5, top),
      Offset(right - 5, top),
      Paint()
        ..color = Colors.white.withValues(alpha: .78)
        ..strokeWidth = 2.4,
    );
  }

  void _fluid(
    Canvas canvas,
    List<int> layers,
    double opacity,
    double left,
    double right,
    double top,
    double bottom,
    double h,
  ) {
    if (opacity <= .001) return;
    final innerLeft = left + 3;
    final innerRight = right - 3;
    final floor = bottom - 3;
    final unit = (floor - top - 5) / 4;
    for (var i = 0; i < layers.length && i < 4; i++) {
      final color = Brand.liquids[layers[i] % Brand.liquids.length];
      final y = floor - unit * (i + 1);
      final rect = Rect.fromLTRB(innerLeft, y, innerRight, y + unit + 1);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.lerp(color, Colors.white, .22)!.withValues(alpha: opacity),
              color.withValues(alpha: opacity),
              Color.lerp(color, Colors.black, .16)!.withValues(alpha: opacity),
            ],
          ).createShader(rect),
      );
      canvas.drawLine(
        Offset(innerLeft + 3, y + 3),
        Offset(innerRight - 3, y + 3),
        Paint()
          ..color = Colors.white.withValues(alpha: .25 * opacity)
          ..strokeWidth = 1.3,
      );
      canvas.drawCircle(
        Offset(innerRight - 9, y + unit * .55),
        math.min(h * .014, 2.3),
        Paint()..color = Colors.white.withValues(alpha: .35 * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlassPainter old) =>
      old.progress != progress ||
      old.selected != selected ||
      !listEquals(old.previous, previous) ||
      !listEquals(old.current, current);
}
