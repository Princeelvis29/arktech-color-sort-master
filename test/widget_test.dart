import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/main.dart';
import 'package:colorsortmaster/services/game_progress.dart';

void main() {
  testWidgets('Splash opens premium home and level one game', (tester) async {
    final progress = GameProgress.memory()
      ..updateSettings(sound: false, haptics: false, motion: true);
    await tester.pumpWidget(ArktechColorSortApp(progress: progress));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    expect(find.text('COLOR SORT'), findsOneWidget);
    expect(find.text('MASTER'), findsOneWidget);
    await tester.ensureVisible(find.text('PLAY NOW'));
    await tester.tap(find.text('PLAY NOW'));
    await tester.pumpAndSettle();
    expect(find.text('LEVEL 01'), findsOneWidget);
    expect(find.byKey(const Key('bottle-0')), findsOneWidget);
  });

  testWidgets('Level chooser keeps unfinished levels locked', (tester) async {
    final progress = GameProgress.memory()
      ..updateSettings(sound: false, haptics: false, motion: true);
    await tester.pumpWidget(ArktechColorSortApp(progress: progress));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CHOOSE LEVEL'));
    await tester.tap(find.text('CHOOSE LEVEL'));
    await tester.pumpAndSettle();
    final locked = tester.widget<OutlinedButton>(
      find.byKey(const Key('level-2')),
    );
    expect(locked.onPressed, isNull);
    final ready = tester.widget<OutlinedButton>(
      find.byKey(const Key('level-1')),
    );
    expect(ready.onPressed, isNotNull);
  });
}
