import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/main.dart';

void main() {
  testWidgets('Home launches first playable puzzle', (tester) async {
    await tester.pumpWidget(const ArktechColorSortApp());
    expect(find.text('COLOR SORT'), findsOneWidget);
    expect(find.text('MASTER'), findsOneWidget);
    await tester.ensureVisible(find.text('PLAY NOW'));
    await tester.tap(find.text('PLAY NOW'));
    await tester.pumpAndSettle();
    expect(find.text('LEVEL 01'), findsOneWidget);
    expect(find.byKey(const Key('bottle-0')), findsOneWidget);
  });
}
