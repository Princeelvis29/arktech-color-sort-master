import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/services/game_progress.dart';
import 'package:colorsortmaster/game/puzzle_controller.dart';
import 'package:colorsortmaster/game/puzzle_level.dart';

void main() {
  test('Only the first level starts unlocked', () {
    final progress = GameProgress.memory();
    expect(progress.isUnlocked(0), isTrue);
    expect(progress.isUnlocked(1), isFalse);
    expect(progress.coins, 0);
  });

  test('Level win unlocks next level and grants one-time coins', () {
    final progress = GameProgress.memory();
    expect(progress.finishLevel(0, 9), 25);
    expect(progress.isUnlocked(1), isTrue);
    expect(progress.starsFor(0), 3);
    expect(progress.coins, 25);
    expect(progress.finishLevel(0, 16), 0);
    expect(progress.coins, 25);
    expect(progress.starsFor(0), 3);
    expect(progress.finishLevel(2, 5), 0); // cannot skip locked levels
  });

  test('Unfinished game state restores correctly and rejects corruption', () {
    final game = PuzzleController(PuzzleLevel.demo[0]);
    game.tapBottle(0);
    game.tapBottle(3);
    final snapshot = game.snapshot();
    final restored = PuzzleController(PuzzleLevel.demo[0]);
    expect(restored.restore(snapshot), isTrue);
    expect(restored.bottles, game.bottles);
    expect(restored.moves, 1);
    restored.undo();
    expect(restored.moves, 0);
    expect(restored.bottles, PuzzleLevel.demo[0].bottles);
    final damaged = {
      ...snapshot,
      'bottles': [
        [999],
        [],
        [],
        [],
        [],
      ],
    };
    expect(restored.restore(damaged), isFalse);
    game.dispose();
    restored.dispose();
  });

  test('Snapshot storage is associated with the correct level', () {
    final progress = GameProgress.memory();
    final game = PuzzleController(PuzzleLevel.demo[0]);
    progress.saveSession(0, game.snapshot());
    expect(progress.sessionFor(0), isNotNull);
    expect(progress.sessionFor(1), isNull);
    expect(progress.resumeLevel, 0);
    progress.finishLevel(0, 10);
    expect(progress.sessionFor(0), isNull);
    expect(progress.resumeLevel, 1);
    game.dispose();
  });
}
