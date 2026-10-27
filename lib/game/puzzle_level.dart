/// Fixed launch-prototype puzzles; all 10 layouts were verified solvable.
/// A bottle's first value is the BOTTOM layer and its last is the TOP layer.
class PuzzleLevel {
  const PuzzleLevel({required this.number, required this.name, required this.bottles});

  final int number;
  final String name;
  final List<List<int>> bottles;

  static const int capacity = 4;

  static const List<PuzzleLevel> demo = [
    PuzzleLevel(number: 1, name: 'First Splash', bottles: [[0, 2, 0, 2], [2, 1, 0, 2], [1, 0, 1, 1], [], []]),
    PuzzleLevel(number: 2, name: 'Rainbow Drops', bottles: [[2, 0, 0, 1], [2, 1, 1, 0], [0, 2, 1, 2], [], []]),
    PuzzleLevel(number: 3, name: 'Color Twist', bottles: [[1, 2, 1, 2], [0, 2, 1, 2], [0, 1, 0, 0], [], []]),
    PuzzleLevel(number: 4, name: 'Crystal Pour', bottles: [[2, 0, 2, 1], [0, 0, 0, 1], [1, 2, 1, 2], [], []]),
    PuzzleLevel(number: 5, name: 'Prism Flow', bottles: [[2, 2, 2, 1], [1, 0, 1, 0], [0, 1, 2, 0], [], []]),
    PuzzleLevel(number: 6, name: 'Candy Cascade', bottles: [[0, 1, 2, 0], [2, 3, 1, 0], [0, 2, 2, 3], [1, 3, 1, 3], [], []]),
    PuzzleLevel(number: 7, name: 'Azure Valley', bottles: [[3, 1, 1, 2], [1, 3, 0, 2], [3, 0, 0, 1], [3, 0, 2, 2], [], []]),
    PuzzleLevel(number: 8, name: 'Neon Drops', bottles: [[0, 3, 0, 3], [0, 1, 1, 2], [3, 2, 1, 1], [3, 2, 0, 2], [], []]),
    PuzzleLevel(number: 9, name: 'Royal Rainbow', bottles: [[0, 3, 1, 2], [2, 3, 0, 1], [2, 3, 2, 1], [0, 1, 0, 3], [], []]),
    PuzzleLevel(number: 10, name: 'Master Mix', bottles: [[1, 3, 2, 3], [0, 3, 2, 1], [2, 0, 0, 0], [1, 1, 2, 3], [], []]),
  ];
}
