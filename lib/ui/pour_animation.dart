import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'painted_bottle.dart';

/// A pour measured in root-overlay coordinates. The lip of the tilting bottle
/// is placed beside (not on top of) the receiving bottle's opening.
@immutable
class PourFlightGeometry {
  const PourFlightGeometry({
    required this.source,
    required this.target,
    required this.direction,
    required this.travel,
    required this.mouth,
    required this.receivingMouth,
  });

  static const double maxTilt = 1.07; // ~61 degrees toward the destination

  final Rect source;
  final Rect target;
  final double direction;
  final Offset travel;
  final Offset mouth;
  final Offset receivingMouth;

  factory PourFlightGeometry.between(Rect source, Rect target) {
    final direction = target.center.dx >= source.center.dx ? 1.0 : -1.0;
    final mouthGap = (source.width * .52).clamp(26.0, 44.0);
    final verticalGap = (source.height * .29).clamp(29.0, 48.0);
    final mouth = Offset(
      target.center.dx - direction * mouthGap,
      target.top - verticalGap,
    );
    final receivingMouth = Offset(
      target.center.dx,
      target.top + target.height * .07,
    );
    // Transform.rotate uses Alignment.center. The glass opening is centered
    // horizontally, 7% down its height, and rotates around the bottle center.
    final localLip = Offset(0, -source.height * .43);
    final rotatedLip = rotate(localLip, direction * maxTilt);
    final travel = mouth - (source.center + rotatedLip);
    return PourFlightGeometry(
      source: source,
      target: target,
      direction: direction,
      travel: travel,
      mouth: mouth,
      receivingMouth: receivingMouth,
    );
  }

  static Offset rotate(Offset v, double radians) => Offset(
    v.dx * math.cos(radians) - v.dy * math.sin(radians),
    v.dx * math.sin(radians) + v.dy * math.cos(radians),
  );

  static double smooth(double t) {
    final x = t.clamp(0.0, 1.0).toDouble();
    return x * x * (3 - 2 * x);
  }

  /// The bottle arrives at its pour position, holds, then settles back.
  double getMotion(double progress) =>
      smooth(progress / .30) * (1 - smooth((progress - .82) / .18));

  double getTilt(double progress) =>
      smooth((progress - .02) / .30) * (1 - smooth((progress - .82) / .18));

  Offset mouthAt(double progress) {
    final angle = direction * maxTilt * getTilt(progress);
    final lip = rotate(Offset(0, -source.height * .43), angle);
    return source.center + travel * getMotion(progress) + lip;
  }
}

/// Drawn in an IgnorePointer overlay; game logic and actual hit targets remain
/// in the board. No animation ever transfers or spends coins by itself.
class PourFlightOverlay extends StatelessWidget {
  const PourFlightOverlay({
    super.key,
    required this.flight,
    required this.progress,
    required this.sourceLayers,
    required this.pouredUnits,
    required this.color,
    required this.bottleHeight,
    required this.theme,
  });

  final PourFlightGeometry flight;
  final double progress;
  final List<int> sourceLayers;
  final int pouredUnits;
  final Color color;
  final double bottleHeight;
  final String theme;

  static double smooth(double t) => PourFlightGeometry.smooth(t);

  @override
  Widget build(BuildContext context) {
    final fraction = smooth((progress - .40) / .37);
    final removed = math.min(
      sourceLayers.length,
      math.max(0, (fraction * pouredUnits).round()),
    );
    final visibleLayers = sourceLayers.sublist(
      0,
      sourceLayers.length - removed,
    );
    final glow =
        smooth((progress - .30) / .16) * (1 - smooth((progress - .78) / .11));

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Paint under the flying bottle, so the stream visually emerges from
          // its lip while remaining visible all the way to the receiving rim.
          CustomPaint(
            painter: PourStreamPainter(
              flight: flight,
              progress: progress,
              color: color,
            ),
          ),
          Positioned(
            left: flight.target.left - 5,
            top: flight.target.top - 5,
            width: flight.target.width + 10,
            height: flight.target.height + 10,
            child: Opacity(
              opacity: (.58 * glow).clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .18),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: flight.source.left,
            top: flight.source.top,
            width: flight.source.width,
            height: flight.source.height,
            child: Transform.translate(
              offset: flight.travel * flight.getMotion(progress),
              child: Transform.rotate(
                alignment: Alignment.center,
                angle:
                    flight.direction *
                    PourFlightGeometry.maxTilt *
                    flight.getTilt(progress),
                child: Center(
                  child: PaintedBottle(
                    layers: visibleLayers,
                    height: bottleHeight,
                    theme: theme,
                    reducedMotion: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight stream with a sparkling core and small deterministic splashes.
/// The painter's stream start uses the EXACT same rotation and translation as
/// the flying source bottle, so it does not float apart from the glass lip.
class PourStreamPainter extends CustomPainter {
  const PourStreamPainter({
    required this.flight,
    required this.progress,
    required this.color,
  });

  final PourFlightGeometry flight;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < .33 || progress >= .85) return;
    final reveal = PourFlightGeometry.smooth((progress - .33) / .12);
    final fade = 1 - PourFlightGeometry.smooth((progress - .76) / .09);
    final opacity = (reveal * fade).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    final start = flight.mouthAt(progress);
    final end = flight.receivingMouth;
    final drop = math.max(12.0, end.dy - start.dy);
    final dx = end.dx - start.dx;
    final curve = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + dx * .42,
        start.dy + drop * .13,
        end.dx - dx * .12,
        end.dy - drop * .18,
        end.dx,
        end.dy,
      );
    final metrics = curve.computeMetrics().toList();
    if (metrics.isEmpty || metrics.first.length <= 0) return;
    final metric = metrics.first;
    final drawn = metric.extractPath(0, metric.length * reveal);

    canvas.drawPath(
      drawn,
      Paint()
        ..color = color.withValues(alpha: .43 * opacity)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..color = color.withValues(alpha: .94 * opacity)
        ..strokeWidth = 5.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..color = Colors.white.withValues(alpha: .50 * opacity)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Small flowing beads, not large particles that obscure gameplay.
    for (var i = 0; i < 3; i++) {
      final t = ((progress * 3.6 + i / 3) % 1.0).clamp(.05, .96);
      final tangent = metric.getTangentForOffset(metric.length * t * reveal);
      if (tangent == null) continue;
      canvas.drawCircle(
        tangent.position,
        i == 0 ? 2.3 : 1.4,
        Paint()..color = Colors.white.withValues(alpha: .64 * opacity),
      );
    }

    // Landing ripples and tiny splash beads, drawn only as liquid arrives.
    final splash = PourFlightGeometry.smooth((progress - .42) / .13) * fade;
    if (splash > 0) {
      final radius = 5 + 6 * math.sin((progress - .42) * math.pi * 4).abs();
      canvas.drawOval(
        Rect.fromCenter(
          center: end + const Offset(0, 2),
          width: radius * 2.3,
          height: radius * .6,
        ),
        Paint()
          ..color = color.withValues(alpha: .62 * splash)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      for (var i = 0; i < 4; i++) {
        final phase = progress * 6 + i * 1.57;
        final bead =
            end +
            Offset(
              math.cos(phase) * (5 + i * 2),
              -3 - math.sin(phase).abs() * (5 + i * 1.5),
            );
        canvas.drawCircle(
          bead,
          i.isEven ? 1.8 : 1.2,
          Paint()..color = color.withValues(alpha: .78 * splash),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PourStreamPainter old) =>
      old.progress != progress || old.color != color || old.flight != flight;
}
