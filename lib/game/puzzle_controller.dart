import 'package:flutter/foundation.dart';
import 'puzzle_level.dart';

/// The puzzle logic does not depend on screens or rendering.
class PuzzleController extends ChangeNotifier {
  PuzzleController(this.level) : _bottles = _copy(level.bottles);

  final PuzzleLevel level;
  List<List<int>> _bottles;
  final List<List<List<int>>> _history = [];
  int? _selected;
  int _moves = 0;

  List<List<int>> get bottles =>
      _bottles.map((b) => List<int>.unmodifiable(b)).toList(growable: false);
  int? get selected => _selected;
  int get moves => _moves;
  bool get canUndo => _history.isNotEmpty;
  bool get isComplete => _bottles.every(
    (b) =>
        b.isEmpty ||
        (b.length == PuzzleLevel.capacity &&
            b.every((color) => color == b.first)),
  );

  static List<List<int>> _copy(List<List<int>> source) =>
      source.map((b) => List<int>.from(b)).toList();

  /// Returns number of liquid layers that may legally be transferred.
  int transferableCount(int from, int to) {
    if (from == to ||
        from < 0 ||
        to < 0 ||
        from >= _bottles.length ||
        to >= _bottles.length) {
      return 0;
    }
    final source = _bottles[from];
    final destination = _bottles[to];
    if (source.isEmpty || destination.length == PuzzleLevel.capacity) return 0;
    final top = source.last;
    if (destination.isNotEmpty && destination.last != top) return 0;
    int matching = 0;
    for (int k = source.length - 1; k >= 0 && source[k] == top; k--) {
      matching++;
    }
    final available = PuzzleLevel.capacity - destination.length;
    return matching < available ? matching : available;
  }

  /// Select a source bottle then tap the destination bottle.
  /// Returns true only when a legal pour was performed.
  bool tapBottle(int index) {
    if (index < 0 || index >= _bottles.length || isComplete) return false;
    if (_selected == null) {
      if (_bottles[index].isNotEmpty) _selected = index;
      notifyListeners();
      return false;
    }
    if (_selected == index) {
      _selected = null;
      notifyListeners();
      return false;
    }
    final from = _selected!;
    final amount = transferableCount(from, index);
    if (amount <= 0) {
      // A nonempty invalid destination becomes the newly selected source.
      _selected = _bottles[index].isNotEmpty ? index : from;
      notifyListeners();
      return false;
    }
    _history.add(_copy(_bottles));
    final color = _bottles[from].last;
    _bottles[from].removeRange(
      _bottles[from].length - amount,
      _bottles[from].length,
    );
    _bottles[index].addAll(List<int>.filled(amount, color));
    _moves++;
    _selected = null;
    notifyListeners();
    return true;
  }

  void undo() {
    if (_history.isEmpty) return;
    _bottles = _history.removeLast();
    _moves--;
    _selected = null;
    notifyListeners();
  }

  void restart() {
    _bottles = _copy(level.bottles);
    _history.clear();
    _moves = 0;
    _selected = null;
    notifyListeners();
  }
}
