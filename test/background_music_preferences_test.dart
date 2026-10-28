import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/services/game_progress.dart';

void main() {
  test('Music is enabled by default for the new game experience', () {
    final progress = GameProgress.memory();
    expect(progress.musicEnabled, isTrue);
    expect(progress.toJson()['musicPrefV1'], isTrue);
  });

  test('Players can turn music off and back on using Settings', () {
    final progress = GameProgress.memory();
    progress.updateSettings(music: false);
    expect(progress.musicEnabled, isFalse);
    expect(progress.toJson()['music'], isFalse);
    progress.updateSettings(music: true);
    expect(progress.musicEnabled, isTrue);
    expect(progress.toJson()['music'], isTrue);
  });
}
