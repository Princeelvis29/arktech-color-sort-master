import 'package:flutter/foundation.dart';
import 'puzzle_level.dart';

/// Pure puzzle logic: first entry of each bottle is the bottom layer.
class PuzzleController extends ChangeNotifier {
  PuzzleController(this.level) : _bottles = _copy(level.bottles);

  final PuzzleLevel level;
  List<List<int>> _bottles;
  final List<List<List<int>>> _history = [];
  int? _selected;
  int _moves = 0;
  int _extraBottles = 0;
  int get extraBottles => _extraBottles;
  int? lastPourFrom;
  int? lastPourTo;

  List<List<int>> get bottles => _bottles
      .map((bottle) => List<int>.unmodifiable(bottle))
      .toList(growable: false);
  int? get selected => _selected;
  int get moves => _moves;
  bool get canUndo => _history.isNotEmpty;
  bool get isComplete => _bottles.every(
    (bottle) =>
        bottle.isEmpty ||
        (bottle.length == PuzzleLevel.capacity &&
            bottle.every((color) => color == bottle.first)),
  );

  static List<List<int>> _copy(List<List<int>> source) =>
      source.map((bottle) => List<int>.from(bottle)).toList();

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
    final color = source.last;
    if (destination.isNotEmpty && destination.last != color) return 0;
    var matching = 0;
    for (var i = source.length - 1; i >= 0 && source[i] == color; i--) {
      matching++;
    }
    final available = PuzzleLevel.capacity - destination.length;
    return matching < available ? matching : available;
  }

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
    if (amount == 0) {
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
    lastPourFrom = from;
    lastPourTo = index;
    _selected = null;
    notifyListeners();
    return true;
  }

  bool addExtraBottle() {
    if (_extraBottles >= 1 || isComplete) return false;
    _bottles.add(<int>[]);
    _extraBottles++;
    _selected = null;
    _history.clear();
    notifyListeners();
    return true;
  }

  void undo() {
    if (_history.isEmpty) return;
    _bottles = _history.removeLast();
    _moves--;
    _selected = null;
    lastPourFrom = null;
    lastPourTo = null;
    notifyListeners();
  }

  void restart() {
    _bottles = _copy(level.bottles);
    if (_extraBottles == 1) _bottles.add(<int>[]);
    _history.clear();
    _moves = 0;
    _selected = null;
    lastPourFrom = null;
    lastPourTo = null;
    notifyListeners();
  }

  Map<String, dynamic> snapshot() => {
    'bottles': _copy(_bottles),
    'extraBottles': _extraBottles,
    'moves': _moves,
    'history': _history.map(_copy).toList(),
  };

  /// Refuse corrupt saves and saves that change the level's color inventory.
  bool restore(Map<String, dynamic> saved) {
    final extras = saved['extraBottles'] is int
        ? saved['extraBottles'] as int
        : 0;
    if (extras < 0 || extras > 1) return false;
    final candidate = _parseBoard(saved['bottles'], extras);
    final moves = saved['moves'];
    if (candidate == null ||
        moves is! int ||
        moves < 0 ||
        moves > 100000 ||
        !_sameInventory(level.bottles, candidate)) {
      return false;
    }

    final restoredHistory = <List<List<int>>>[];
    final rawHistory = saved['history'];
    if (rawHistory is List &&
        rawHistory.length <= moves &&
        rawHistory.length <= 500) {
      for (final previous in rawHistory) {
        final board = _parseBoard(previous, extras);
        if (board == null || !_sameInventory(level.bottles, board)) {
          restoredHistory.clear();
          break;
        }
        restoredHistory.add(board);
      }
    }
    _extraBottles = extras;
    _bottles = candidate;
    _history
      ..clear()
      ..addAll(restoredHistory);
    _moves = moves;
    _selected = null;
    notifyListeners();
    return true;
  }

  List<List<int>>? _parseBoard(Object? raw, int extras) {
    if (raw is! List || raw.length != level.bottles.length + extras) {
      return null;
    }
    final board = <List<int>>[];
    for (final bottle in raw) {
      if (bottle is! List || bottle.length > PuzzleLevel.capacity) return null;
      if (bottle.any((color) => color is! int || color < 0 || color >= 6)) {
        return null;
      }
      board.add(List<int>.from(bottle));
    }
    return board;
  }

  static bool _sameInventory(List<List<int>> a, List<List<int>> b) {
    final left = a.expand((bottle) => bottle).toList()..sort();
    final right = b.expand((bottle) => bottle).toList()..sort();
    return listEquals(left, right);
  }
}
