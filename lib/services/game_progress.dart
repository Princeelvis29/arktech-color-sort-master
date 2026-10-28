import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only player progress. No sign-in or network service is required.
class GameProgress extends ChangeNotifier {
  GameProgress._(this._preferences);

  static const _storageKey = 'arktech_color_sort_progress_v3';
  final SharedPreferences? _preferences;

  int highestUnlocked = 0; // zero based: start with level 1 only
  int coins = 0;
  int totalMoves = 0;
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;
  bool reducedMotion = false;
  final Map<int, int> _stars = {};
  Map<String, dynamic>? _session;

  /// Useful for deterministic widget and service tests.
  factory GameProgress.memory() => GameProgress._(null);

  static Future<GameProgress> load() async {
    SharedPreferences? preferences;
    try {
      preferences = await SharedPreferences.getInstance();
    } catch (_) {
      // Permit offline play even if the storage plugin is unavailable.
    }
    final progress = GameProgress._(preferences);
    if (preferences == null) return progress;
    try {
      final raw = preferences.getString(_storageKey);
      if (raw == null) return progress;
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return progress;
      progress.highestUnlocked = _boundedInt(data['unlocked'], 0, 9);
      progress.coins = _boundedInt(data['coins'], 0, 999999);
      progress.totalMoves = _boundedInt(data['moves'], 0, 100000000);
      progress.soundEnabled = data['sound'] is bool
          ? data['sound'] as bool
          : true;
      progress.musicEnabled = data['musicPrefV1'] == true
          ? (data['music'] is bool ? data['music'] as bool : true)
          : true;
      progress.hapticsEnabled = data['haptics'] is bool
          ? data['haptics'] as bool
          : true;
      progress.reducedMotion = data['reduceMotion'] is bool
          ? data['reduceMotion'] as bool
          : false;
      final savedStars = data['stars'];
      if (savedStars is Map) {
        for (var i = 0; i < 10; i++) {
          final number = _boundedInt(savedStars['$i'], 0, 3);
          if (number > 0) progress._stars[i] = number;
        }
      }
      if (data['session'] is Map<String, dynamic>) {
        progress._session = Map<String, dynamic>.from(
          data['session'] as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Corrupt or old data must never stop gameplay.
    }
    return progress;
  }

  static int _boundedInt(Object? value, int min, int max) {
    if (value is! int) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  int get clearedLevels => _stars.length;
  int get earnedStars =>
      _stars.values.fold<int>(0, (sum, value) => sum + value);
  int starsFor(int index) => _stars[index] ?? 0;
  bool isUnlocked(int index) => index >= 0 && index <= highestUnlocked;

  int get resumeLevel {
    final savedLevel = _session?['level'];
    if (savedLevel is int && isUnlocked(savedLevel)) return savedLevel;
    return highestUnlocked;
  }

  Map<String, dynamic>? sessionFor(int levelIndex) {
    if (_session?['level'] != levelIndex) return null;
    final game = _session?['game'];
    if (game is Map<String, dynamic>) return Map<String, dynamic>.from(game);
    return null;
  }

  void saveSession(int levelIndex, Map<String, dynamic> game) {
    if (!isUnlocked(levelIndex)) return;
    _session = {'level': levelIndex, 'game': game};
    _persist();
  }

  void clearSession() {
    _session = null;
    _persist();
  }

  /// One-time coin reward; replays can improve stars without farming coins.
  int finishLevel(int index, int moves) {
    if (!isUnlocked(index)) return 0;
    final stars = moves <= 12 ? 3 : (moves <= 20 ? 2 : 1);
    final firstClear = !_stars.containsKey(index);
    if (stars > starsFor(index)) _stars[index] = stars;
    if (firstClear) {
      coins += 25;
      totalMoves += moves;
    }
    if (index < 9 && index + 1 > highestUnlocked) highestUnlocked = index + 1;
    _session = null;
    notifyListeners();
    _persist();
    return firstClear ? 25 : 0;
  }

  void updateSettings({bool? sound, bool? music, bool? haptics, bool? motion}) {
    if (sound != null) soundEnabled = sound;
    if (music != null) musicEnabled = music;
    if (haptics != null) hapticsEnabled = haptics;
    if (motion != null) reducedMotion = motion;
    notifyListeners();
    _persist();
  }

  Map<String, dynamic> toJson() => {
    'schema': 3,
    'unlocked': highestUnlocked,
    'coins': coins,
    'moves': totalMoves,
    'sound': soundEnabled,
    'music': musicEnabled,
    'musicPrefV1': true,
    'haptics': hapticsEnabled,
    'reduceMotion': reducedMotion,
    'stars': {for (final entry in _stars.entries) '${entry.key}': entry.value},
    'session': _session,
  };

  void _persist() {
    final preferences = _preferences;
    if (preferences == null) return;
    preferences
        .setString(_storageKey, jsonEncode(toJson()))
        .catchError((Object _) => false);
  }
}
