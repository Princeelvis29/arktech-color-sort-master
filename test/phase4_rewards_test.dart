import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/services/game_progress.dart';

void main() {
  test('daily claim is once per calendar day and preserves streak', () {
    final progress = GameProgress.memory();
    final today = DateTime(2026, 10, 28, 9);
    expect(progress.claimDaily(today), 40);
    expect(progress.claimDaily(today), 0);
    expect(progress.dailyStreak, 1);
    expect(progress.claimDaily(DateTime(2026, 10, 29, 12)), 45);
    expect(progress.dailyStreak, 2);
    expect(progress.claimDaily(DateTime(2026, 11, 1, 12)), 40);
    expect(progress.dailyStreak, 1);
  });

  test('achievement reward can be claimed only once', () {
    final progress = GameProgress.memory();
    progress.finishLevel(0, 9);
    expect(progress.claimAchievement('first'), true);
    expect(progress.claimAchievement('first'), false);
    expect(progress.claimAchievement('master'), false);
    expect(progress.coins, 55);
  });

  test('themes cost coins once, preserve active theme', () {
    final progress = GameProgress.memory();
    progress.claimDaily(DateTime(2026, 10, 28));
    progress.finishLevel(0, 9);
    progress.claimAchievement('first');
    expect(progress.coins, 95);
    expect(progress.unlockTheme('neon'), false);
    progress.finishLevel(1, 15);
    expect(progress.unlockTheme('neon'), true);
    expect(progress.activeTheme, 'neon');
    expect(progress.ownedThemes.contains('neon'), true);
    expect(progress.selectTheme('crystal'), true);
    expect(progress.selectTheme('neon'), true);
  });

  test('daily challenge reward is awarded once and date-dependent', () {
    final progress = GameProgress.memory();
    expect(progress.awardDailyChallenge(DateTime(2026, 10, 28)), 20);
    expect(progress.awardDailyChallenge(DateTime(2026, 10, 28)), 0);
    expect(progress.awardDailyChallenge(DateTime(2026, 10, 29)), 20);
  });

  test('Phase 3 progress key and saved level session remain compatible', () {
    final progress = GameProgress.memory();
    expect(progress.toJson()['schema'], 4);
    expect(progress.finishLevel(0, 9), 25);
    expect(progress.isUnlocked(1), true);
    expect(progress.resumeLevel, 1);
  });
}
