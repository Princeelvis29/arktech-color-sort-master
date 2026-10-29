import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/game/puzzle_level.dart';
import 'package:colorsortmaster/game/puzzle_solver.dart';
import 'package:colorsortmaster/game/puzzle_controller.dart';

void main() {
  test('150 levels, six chapters, four copies of each color', () {
    expect(PuzzleLevel.demo.length, 150);
    expect(PuzzleLevel.chapters.length, 6);
    for (var i = 0; i < 150; i++) {
      final level = PuzzleLevel.demo[i];
      expect(level.number, i + 1);
      expect(level.bottles.every((b) => b.length <= 4), true);
      final inventory = <int, int>{};
      for (final color in level.bottles.expand((b) => b)) {
        inventory[color] = (inventory[color] ?? 0) + 1;
      }
      expect(inventory.values.every((v) => v == 4), true);
      expect(level.bottles.where((b) => b.isEmpty).length, 2);
      expect(PuzzleSolver.isSolved(level.bottles), false);
    }
  });

  test('solver returns a legal next move for all 150 puzzle layouts', () {
    for (final level in PuzzleLevel.demo) {
      final hint = PuzzleSolver.hint(level.bottles);
      expect(hint, isNotNull, reason: 'Level ${level.number}');
      final game = PuzzleController(level);
      game.tapBottle(hint![0]);
      final moved = game.tapBottle(hint[1]);
      expect(moved, true, reason: 'Level ${level.number}');
      game.dispose();
    }
  });

  test('purchased extra bottle survives snapshots and restart', () {
    final game = PuzzleController(PuzzleLevel.demo[2]);
    expect(game.addExtraBottle(), true);
    expect(game.addExtraBottle(), false);
    expect(game.bottles.length, 6);
    final restored = PuzzleController(PuzzleLevel.demo[2]);
    expect(restored.restore(game.snapshot()), true);
    expect(restored.extraBottles, 1);
    restored.restart();
    expect(restored.bottles.length, 6);
    game.dispose();
    restored.dispose();
  });
}
