import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/ui/pour_animation.dart';

void main() {
  test('Rightward pour aligns flying lip beside the receiving rim', () {
    const source = Rect.fromLTWH(20, 210, 70, 140);
    const target = Rect.fromLTWH(220, 210, 70, 140);
    final flight = PourFlightGeometry.between(source, target);
    expect(flight.direction, 1);
    expect(flight.mouthAt(.54).dx, closeTo(flight.mouth.dx, .0001));
    expect(flight.mouthAt(.54).dy, closeTo(flight.mouth.dy, .0001));
    expect(flight.mouth.dx, lessThan(flight.receivingMouth.dx));
    expect(flight.mouth.dy, lessThan(target.top));
    // The bottle opening must be outside the receiving bottle's center.
    expect(flight.mouth.dx, lessThan(target.center.dx - 25));
  });

  test('Leftward pour mirrors the orientation and opening', () {
    const source = Rect.fromLTWH(220, 210, 70, 140);
    const target = Rect.fromLTWH(20, 210, 70, 140);
    final flight = PourFlightGeometry.between(source, target);
    expect(flight.direction, -1);
    expect(flight.mouthAt(.54), closeToOffset(flight.mouth, .0001));
    expect(flight.mouth.dx, greaterThan(flight.receivingMouth.dx));
    expect(flight.mouth.dy, lessThan(target.top));
  });

  test('Cross-row pours land at the top opening', () {
    const source = Rect.fromLTWH(220, 380, 60, 120);
    const target = Rect.fromLTWH(20, 130, 60, 120);
    final flight = PourFlightGeometry.between(source, target);
    expect(flight.travel.dy, lessThan(0));
    expect(flight.receivingMouth.dx, target.center.dx);
    expect(flight.receivingMouth.dy, closeTo(target.top + 8.4, .001));
    expect(flight.mouthAt(.52), closeToOffset(flight.mouth, .0001));
  });

  test('Lip follows the bottle during travel and return', () {
    const source = Rect.fromLTWH(25, 250, 60, 120);
    const target = Rect.fromLTWH(200, 170, 60, 120);
    final flight = PourFlightGeometry.between(source, target);
    final restingMouth = source.topCenter + Offset(0, source.height * .07);
    expect(flight.mouthAt(0), closeToOffset(restingMouth, .0001));
    expect(flight.mouthAt(1), closeToOffset(restingMouth, .0001));
    expect(flight.mouthAt(.55), closeToOffset(flight.mouth, .0001));
  });

  test('Geometry remains finite on a compact mobile board', () {
    const source = Rect.fromLTWH(15, 200, 54, 112);
    const target = Rect.fromLTWH(74, 200, 54, 112);
    final flight = PourFlightGeometry.between(source, target);
    expect(flight.mouthAt(.55).dx.isFinite, isTrue);
    expect(flight.mouthAt(.55).dy.isFinite, isTrue);
    expect(flight.mouth.dy, lessThan(flight.receivingMouth.dy));
  });

  test('Smooth easing handles out-of-range values', () {
    expect(PourFlightOverlay.smooth(-3), 0);
    expect(PourFlightOverlay.smooth(0), 0);
    expect(PourFlightOverlay.smooth(1), 1);
    expect(PourFlightOverlay.smooth(3), 1);
  });

  testWidgets('Flow painter renders mid-pour without errors', (tester) async {
    const source = Rect.fromLTWH(30, 80, 65, 140);
    const target = Rect.fromLTWH(180, 200, 65, 140);
    final flight = PourFlightGeometry.between(source, target);
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.expand(
          child: CustomPaint(
            painter: PourStreamPainter(
              flight: flight,
              progress: .55,
              color: Colors.cyan,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

Matcher closeToOffset(Offset target, double tolerance) => predicate<Offset>(
  (actual) =>
      (actual.dx - target.dx).abs() <= tolerance &&
      (actual.dy - target.dy).abs() <= tolerance,
  'offset close to $target within $tolerance',
);
