/// Bounded search solver. Runs in a background isolate on native platforms
/// via Flutter's compute(); on web it yields a bounded result.
class PuzzleSolver {
  static const int capacity = 4;

  /// A legal next move for the CURRENT board, or null if the search budget ends.
  static List<int>? hint(List<List<int>> board) {
    final initial = board.map((tube) => List<int>.from(tube)).toList();
    final seen = <String, int>{};
    var visited = 0;
    final result = _search(initial, 60, seen, () => ++visited <= 20000);
    return result;
  }

  static bool isSolved(List<List<int>> board) => board.every(
    (b) => b.isEmpty || (b.length == capacity && b.every((v) => v == b.first)),
  );

  static String _key(List<List<int>> board) {
    // Bottle order is irrelevant to the feasibility of completing a puzzle.
    final values = board.map((b) => b.join(',')).toList()..sort();
    return values.join('|');
  }

  static List<int>? _search(
    List<List<int>> board,
    int remaining,
    Map<String, int> seen,
    bool Function() keepSearching,
  ) {
    if (!keepSearching()) return null;
    if (isSolved(board)) return const [-1, -1];
    if (remaining == 0) return null;
    final key = _key(board);
    if ((seen[key] ?? -1) >= remaining) return null;
    seen[key] = remaining;
    final options = <_Move>[];
    final empty = board.indexWhere((b) => b.isEmpty);
    for (var i = 0; i < board.length; i++) {
      final from = board[i];
      if (from.isEmpty ||
          (from.length == capacity && from.every((v) => v == from.first))) {
        continue;
      }
      final color = from.last;
      var contiguous = 0;
      for (var x = from.length - 1; x >= 0 && from[x] == color; x--) {
        contiguous++;
      }
      for (var j = 0; j < board.length; j++) {
        if (i == j) continue;
        final to = board[j];
        if (to.length >= capacity || (to.isNotEmpty && to.last != color)) {
          continue;
        }
        if (to.isEmpty && (j != empty || contiguous == from.length)) continue;
        final available = capacity - to.length;
        final count = contiguous < available ? contiguous : available;
        if (count == 0) continue;
        final rank =
            (to.isEmpty ? 4 : 0) -
            (count < 3 ? count : 3) -
            (to.length + count == capacity ? 2 : 0) -
            (from.length == count ? 1 : 0);
        options.add(_Move(i, j, count, rank));
      }
    }
    options.sort((a, b) {
      final score = a.rank.compareTo(b.rank);
      if (score != 0) return score;
      final source = a.from.compareTo(b.from);
      return source != 0 ? source : a.to.compareTo(b.to);
    });
    for (final move in options) {
      final next = board.map((b) => List<int>.from(b)).toList();
      final source = next[move.from];
      final color = source.last;
      source.removeRange(source.length - move.amount, source.length);
      next[move.to].addAll(List<int>.filled(move.amount, color));
      final after = _search(next, remaining - 1, seen, keepSearching);
      if (after != null) return [move.from, move.to];
    }
    return null;
  }
}

class _Move {
  const _Move(this.from, this.to, this.amount, this.rank);
  final int from;
  final int to;
  final int amount;
  final int rank;
}
