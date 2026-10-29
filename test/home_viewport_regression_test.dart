import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/services/game_audio.dart';
import 'package:colorsortmaster/services/game_progress.dart';
import 'package:colorsortmaster/ui/home_screen.dart';

void main() {
  testWidgets('home survives transient tiny viewports and remains scrollable', (
    tester,
  ) async {
    final progress = GameProgress.memory()
      ..updateSettings(
        sound: false,
        music: false,
        haptics: false,
        motion: true,
      );
    final audio = GameAudio(progress);
    addTearDown(audio.dispose);
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(progress: progress, audio: audio),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    for (final size in <Size>[
      const Size(320, 640),
      const Size(320, 1), // Chrome device toolbar can briefly shrink to 1 px.
      const Size(320, 640),
      const Size(360, 800),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'viewport $size');
    }

    expect(find.text('PLAY NOW'), findsOneWidget);
    await tester.ensureVisible(find.text('THEMES'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
