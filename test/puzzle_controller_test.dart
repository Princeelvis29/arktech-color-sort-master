import 'dart:collection';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/game/puzzle_controller.dart';
import 'package:colorsortmaster/game/puzzle_level.dart';

void main() {
  test('legal pour transfers matching top color and Undo restores board', () {
    final game = PuzzleController(PuzzleLevel.demo[0]);
    final initial = game.bottles;
    expect(game.tapBottle(0), false);
    expect(game.tapBottle(3), true);
    expect(game.moves, 1);
    expect(game.bottles[3], [2]);
    expect(game.bottles[0].length, 3);
    game.undo();
    expect(game.moves, 0);
    expect(game.bottles, initial);
    game.dispose();
  });

  test('invalid pour cannot mix different colors', () {
    final game = PuzzleController(PuzzleLevel.demo[0]);
    final initial = game.bottles;
    game.tapBottle(0); // top color 2
    expect(game.tapBottle(2), false); // top color 1
    expect(game.moves, 0);
    expect(game.bottles, initial);
    game.dispose();
  });

  test('restart resets moves and original bottle arrangement', () {
    final game = PuzzleController(PuzzleLevel.demo[0]);
    game.tapBottle(0);
    game.tapBottle(3);
    game.restart();
    expect(game.moves, 0);
    expect(game.canUndo, false);
    expect(game.bottles, PuzzleLevel.demo[0].bottles);
    game.dispose();
  });

  test('all ten playable levels have correct contents and a solution', () {
    for (final level in PuzzleLevel.demo) {
      expect(level.bottles.where((b) => b.isEmpty).length, 2);
      final colors = <int, int>{};
      for (final bottle in level.bottles) {
        expect(bottle.length, lessThanOrEqualTo(PuzzleLevel.capacity));
        for (final value in bottle) {
          colors.update(value, (previous) => previous + 1, ifAbsent: () => 1);
        }
      }
      for (final count in colors.values) {
        expect(count, PuzzleLevel.capacity);
      }
      expect(
        _hasSolution(level),
        true,
        reason: 'Unsolvable demo level ${level.number}',
      );
    }
  });
}

bool _hasSolution(PuzzleLevel level) {
  final start = level.bottles.map((b) => List<int>.from(b)).toList();
  final queue = Queue<List<List<int>>>()..add(start);
  final visited = <String>{_canonical(start)};
  while (queue.isNotEmpty) {
    final state = queue.removeFirst();
    final won = state.every(
      (b) =>
          b.isEmpty ||
          (b.length == PuzzleLevel.capacity && b.every((v) => v == b.first)),
    );
    if (won) return true;
    for (var from = 0; from < state.length; from++) {
      final source = state[from];
      if (source.isEmpty) continue;
      final color = source.last;
      var amount = 0;
      for (var i = source.length - 1; i >= 0 && source[i] == color; i--) {
        amount++;
      }
      for (var to = 0; to < state.length; to++) {
        final target = state[to];
        if (from == to ||
            target.length == 4 ||
            (target.isNotEmpty && target.last != color)) {
          continue;
        }
        if (target.isEmpty && source.length == 4 && amount == 4) continue;
        final transfer = amount < 4 - target.length
            ? amount
            : 4 - target.length;
        final next = state.map((b) => List<int>.from(b)).toList();
        next[from].removeRange(next[from].length - transfer, next[from].length);
        next[to].addAll(List<int>.filled(transfer, color));
        final key = _canonical(next);
        if (visited.add(key)) queue.add(next);
      }
    }
    if (visited.length > 25000) return false;
  }
  return false;
}

String _canonical(List<List<int>> state) {
  final encoded = state.map((b) => b.join(',')).toList()..sort();
  return encoded.join('|');
}
