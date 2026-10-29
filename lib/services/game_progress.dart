import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/puzzle_level.dart';

class Achievement {
  const Achievement(this.id, this.title, this.description, this.threshold);
  final String id;
  final String title;
  final String description;
  final int threshold;
}

/// All progress is saved locally. Storage key is deliberately unchanged from
/// Phase 3 so that existing stars, level unlocks and unfinished games survive.
class GameProgress extends ChangeNotifier {
  GameProgress._(this._preferences);
  static const _storageKey = 'arktech_color_sort_progress_v3';
  final SharedPreferences? _preferences;

  int highestUnlocked = 0;
  int coins = 0;
  int totalMoves = 0;
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;
  bool reducedMotion = false;
  final Map<int, int> _stars = {};
  Map<String, dynamic>? _session;

  String lastDailyClaim = '';
  int dailyStreak = 0;
  String lastDailyChallenge = '';
  final Set<String> claimedAchievements = {};
  final Set<String> ownedThemes = {'crystal'};
  String activeTheme = 'crystal';

  static const themePrices = <String, int>{
    'crystal': 0,
    'neon': 100,
    'ocean': 125,
    'sunset': 150,
    'emerald': 175,
  };

  static const achievements = <Achievement>[
    Achievement('first', 'First Splash', 'Complete 1 puzzle', 1),
    Achievement('ten', 'Color Explorer', 'Complete 10 puzzles', 10),
    Achievement('twentyfive', 'Rainbow Rider', 'Complete 25 puzzles', 25),
    Achievement('fifty', 'Crystal Champion', 'Complete 50 puzzles', 50),
    Achievement('hundred', 'Prism Legend', 'Complete 100 puzzles', 100),
    Achievement('master', 'Sort Master', 'Complete 150 puzzles', 150),
    Achievement('star60', 'Star Collector', 'Collect 60 stars', 60),
    Achievement('star200', 'Star Hunter', 'Collect 200 stars', 200),
    Achievement(
      'streak7',
      'Daily Devotee',
      'Claim rewards for 7 consecutive days',
      7,
    ),
  ];

  factory GameProgress.memory() => GameProgress._(null);

  static Future<GameProgress> load() async {
    SharedPreferences? preferences;
    try {
      preferences = await SharedPreferences.getInstance();
    } catch (_) {}
    final progress = GameProgress._(preferences);
    if (preferences == null) return progress;
    try {
      final raw = preferences.getString(_storageKey);
      if (raw == null) return progress;
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return progress;
      progress.highestUnlocked = _boundedInt(
        data['unlocked'],
        0,
        PuzzleLevel.totalLevels - 1,
      );
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
        for (var i = 0; i < PuzzleLevel.totalLevels; i++) {
          final starCount = _boundedInt(savedStars['$i'], 0, 3);
          if (starCount > 0) progress._stars[i] = starCount;
        }
      }
      if (data['session'] is Map<String, dynamic>) {
        progress._session = Map<String, dynamic>.from(
          data['session'] as Map<String, dynamic>,
        );
      }
      // Older v3 builds stopped at level 10. Unlock level 11 if it was beaten.
      if (progress._stars.containsKey(9) && progress.highestUnlocked < 10) {
        progress.highestUnlocked = 10;
      }
      progress.lastDailyClaim = data['dailyClaim'] is String
          ? data['dailyClaim'] as String
          : '';
      progress.lastDailyChallenge = data['dailyChallenge'] is String
          ? data['dailyChallenge'] as String
          : '';
      progress.dailyStreak = _boundedInt(data['dailyStreak'], 0, 36500);
      if (data['achievementClaims'] is List) {
        progress.claimedAchievements.addAll(
          (data['achievementClaims'] as List).whereType<String>().where(
            (id) => achievements.any((a) => a.id == id),
          ),
        );
      }
      if (data['themes'] is List) {
        progress.ownedThemes.addAll(
          (data['themes'] as List).whereType<String>().where(
            themePrices.containsKey,
          ),
        );
      }
      final savedTheme = data['activeTheme'];
      if (savedTheme is String && progress.ownedThemes.contains(savedTheme)) {
        progress.activeTheme = savedTheme;
      }
    } catch (_) {
      // Damaged save data should not prevent a player from opening the game.
    }
    return progress;
  }

  static int _boundedInt(Object? value, int min, int max) {
    if (value is! int) return min;
    return value < min ? min : (value > max ? max : value);
  }

  int get clearedLevels => _stars.length;
  int get earnedStars => _stars.values.fold<int>(0, (a, b) => a + b);
  int starsFor(int index) => _stars[index] ?? 0;
  bool isUnlocked(int index) =>
      index >= 0 && index < PuzzleLevel.totalLevels && index <= highestUnlocked;

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

  int finishLevel(int index, int moves) {
    if (!isUnlocked(index)) return 0;
    final colors = PuzzleLevel.demo[index].bottles
        .expand((tube) => tube)
        .toSet()
        .length;
    final par = colors * 5;
    final stars = moves <= par ? 3 : (moves <= par + 8 ? 2 : 1);
    final firstClear = !_stars.containsKey(index);
    if (stars > starsFor(index)) _stars[index] = stars;
    if (firstClear) {
      coins += 25;
      totalMoves += moves;
    }
    if (index + 1 < PuzzleLevel.totalLevels && index + 1 > highestUnlocked) {
      highestUnlocked = index + 1;
    }
    _session = null;
    notifyListeners();
    _persist();
    return firstClear ? 25 : 0;
  }

  bool spendCoins(int cost) {
    if (cost <= 0 || coins < cost) return false;
    coins -= cost;
    notifyListeners();
    _persist();
    return true;
  }

  static String dayKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  bool canClaimDaily(DateTime now) => lastDailyClaim != dayKey(now);

  /// Daily reward 40 + 5 for every day in the current streak (max 75).
  int claimDaily(DateTime now) {
    if (!canClaimDaily(now)) return 0;
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    dailyStreak = lastDailyClaim == dayKey(yesterday) ? dailyStreak + 1 : 1;
    lastDailyClaim = dayKey(now);
    final bonus = 40 + (dailyStreak <= 7 ? dailyStreak - 1 : 7) * 5;
    coins += bonus;
    notifyListeners();
    _persist();
    return bonus;
  }

  int dailyChallengeIndex(DateTime date) {
    final day = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(2026, 1, 1)).inDays;
    return (day < 0 ? -day : day) % (highestUnlocked + 1);
  }

  bool get hasDailyChallengeReward =>
      lastDailyChallenge == dayKey(DateTime.now());

  int awardDailyChallenge(DateTime now) {
    if (lastDailyChallenge == dayKey(now)) return 0;
    lastDailyChallenge = dayKey(now);
    coins += 20;
    notifyListeners();
    _persist();
    return 20;
  }

  bool achievementReady(Achievement a) {
    if (a.id.startsWith('star')) return earnedStars >= a.threshold;
    if (a.id == 'streak7') return dailyStreak >= 7;
    return clearedLevels >= a.threshold;
  }

  bool claimAchievement(String id) {
    final matching = achievements.where((a) => a.id == id);
    if (matching.isEmpty ||
        claimedAchievements.contains(id) ||
        !achievementReady(matching.first)) {
      return false;
    }
    claimedAchievements.add(id);
    coins += 30;
    notifyListeners();
    _persist();
    return true;
  }

  bool unlockTheme(String name) {
    final price = themePrices[name];
    if (price == null) return false;
    if (ownedThemes.contains(name)) return selectTheme(name);
    if (!spendCoins(price)) return false;
    ownedThemes.add(name);
    activeTheme = name;
    notifyListeners();
    _persist();
    return true;
  }

  bool selectTheme(String name) {
    if (!ownedThemes.contains(name)) return false;
    activeTheme = name;
    notifyListeners();
    _persist();
    return true;
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
    'schema': 4,
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
    'dailyClaim': lastDailyClaim,
    'dailyStreak': dailyStreak,
    'dailyChallenge': lastDailyChallenge,
    'achievementClaims': claimedAchievements.toList(),
    'themes': ownedThemes.toList(),
    'activeTheme': activeTheme,
  };

  void _persist() {
    final prefs = _preferences;
    if (prefs == null) return;
    prefs
        .setString(_storageKey, jsonEncode(toJson()))
        .catchError((Object _) => false);
  }
}
