import 'dart:async';
import 'package:flutter/material.dart';
import '../game/puzzle_level.dart';
import '../services/game_audio.dart';
import '../services/game_progress.dart';
import 'brand_theme.dart';
import 'contact_screen.dart';
import 'game_screen.dart';
import 'painted_bottle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.progress, required this.audio});
  final GameProgress progress;
  final GameAudio audio;

  void _play(BuildContext context, int index, {bool daily = false}) {
    if (!progress.isUnlocked(index)) return;
    unawaited(audio.tap());
    unawaited(audio.syncMusic());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          levelIndex: index,
          progress: progress,
          audio: audio,
          dailyChallenge: daily,
        ),
      ),
    );
  }

  void _chooseLevel(BuildContext context) {
    unawaited(audio.tap());
    var chapter = 0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF241C54),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: .82,
          child: StatefulBuilder(
            builder: (sheetBodyContext, setSheetState) {
              final chosen = PuzzleLevel.chapters[chapter];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'CHOOSE YOUR LEVEL',
                            style: TextStyle(
                              color: Brand.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close, color: Brand.white),
                        ),
                      ],
                    ),
                    const Text(
                      '150 puzzles across 6 colorful worlds',
                      style: TextStyle(color: Brand.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: PuzzleLevel.chapters.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 7),
                        itemBuilder: (chipContext, i) => ChoiceChip(
                          label: Text('WORLD ${i + 1}'),
                          selected: chapter == i,
                          onSelected: (_) => setSheetState(() => chapter = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      '${chosen.name.toUpperCase()}  •  ${chosen.start}-${chosen.end}',
                      style: const TextStyle(
                        color: Brand.aqua,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: progress,
                        builder: (gridContext, _) => GridView.builder(
                          itemCount: chosen.end - chosen.start + 1,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 100,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: .95,
                              ),
                          itemBuilder: (tileContext, i) {
                            final index = chosen.start - 1 + i;
                            final unlocked = progress.isUnlocked(index);
                            final stars = progress.starsFor(index);
                            return OutlinedButton(
                              key: Key('level-${index + 1}'),
                              onPressed: unlocked
                                  ? () {
                                      Navigator.pop(sheetContext);
                                      _play(context, index);
                                    }
                                  : null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(4),
                                backgroundColor: unlocked
                                    ? Brand.panel
                                    : Brand.navy,
                                side: BorderSide(
                                  color: unlocked ? Brand.aqua : Colors.white24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  unlocked
                                      ? Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Brand.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.lock_rounded,
                                          color: Brand.muted,
                                        ),
                                  Text(
                                    stars > 0
                                        ? List.filled(stars, '★').join()
                                        : (unlocked ? 'READY' : 'LOCKED'),
                                    style: TextStyle(
                                      color: stars > 0
                                          ? Brand.gold
                                          : Brand.muted,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _daily(BuildContext context) {
    unawaited(audio.tap());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF241C54),
      builder: (sheet) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedBuilder(
            animation: progress,
            builder: (_, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: Brand.gold,
                  size: 45,
                ),
                const SizedBox(height: 10),
                const Text(
                  'DAILY REWARD',
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Daily streak: ${progress.dailyStreak} day(s)',
                  style: const TextStyle(color: Brand.muted),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Claim free coins once per day. Streaks earn bonuses!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Brand.muted, fontSize: 12),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: progress.canClaimDaily(DateTime.now())
                        ? () {
                            final reward = progress.claimDaily(DateTime.now());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Daily reward: +$reward coins!'),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.toll_rounded),
                    label: Text(
                      progress.canClaimDaily(DateTime.now())
                          ? 'CLAIM DAILY COINS'
                          : 'COME BACK TOMORROW',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Today’s challenge: Level ${progress.dailyChallengeIndex(DateTime.now()) + 1}',
                  style: const TextStyle(
                    color: Brand.aqua,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Complete the daily level to earn 20 bonus coins.',
                  style: TextStyle(color: Brand.muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheet);
                      _play(
                        context,
                        progress.dailyChallengeIndex(DateTime.now()),
                        daily: true,
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('PLAY DAILY CHALLENGE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _achievements(BuildContext context) {
    unawaited(audio.tap());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF241C54),
      builder: (sheet) => SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: .78,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              children: [
                const Text(
                  'ACHIEVEMENTS',
                  style: TextStyle(
                    color: Brand.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Earn a badge, then claim 30 bonus coins.',
                  style: TextStyle(color: Brand.muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (_, _) => ListView.builder(
                      itemCount: GameProgress.achievements.length,
                      itemBuilder: (_, i) {
                        final achievement = GameProgress.achievements[i];
                        final ready = progress.achievementReady(achievement);
                        final claimed = progress.claimedAchievements.contains(
                          achievement.id,
                        );
                        return Card(
                          color: Brand.panel,
                          child: ListTile(
                            leading: Icon(
                              ready
                                  ? Icons.emoji_events_rounded
                                  : Icons.lock_outline,
                              color: ready ? Brand.gold : Brand.muted,
                            ),
                            title: Text(
                              achievement.title,
                              style: const TextStyle(
                                color: Brand.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              achievement.description,
                              style: const TextStyle(
                                color: Brand.muted,
                                fontSize: 11,
                              ),
                            ),
                            trailing: claimed
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Brand.aqua,
                                  )
                                : ready
                                ? TextButton(
                                    onPressed: () => progress.claimAchievement(
                                      achievement.id,
                                    ),
                                    child: const Text('CLAIM'),
                                  )
                                : const Text(
                                    'LOCKED',
                                    style: TextStyle(
                                      color: Brand.muted,
                                      fontSize: 10,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _themes(BuildContext context) {
    unawaited(audio.tap());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF241C54),
      builder: (sheet) => SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: .72,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              children: [
                const Text(
                  'UNLOCKABLE THEMES',
                  style: TextStyle(
                    color: Brand.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Spend earned coins to unlock new environments.',
                  style: TextStyle(color: Brand.muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (_, _) => ListView(
                      children: [
                        for (final theme in GameProgress.themePrices.entries)
                          Card(
                            color: Brand.panel,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final color in Brand.liquidsFor(
                                      theme.key,
                                    ).take(3))
                                      Container(
                                        width: 12,
                                        height: 27,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  Brand.themeNames[theme.key] ?? theme.key,
                                  style: const TextStyle(
                                    color: Brand.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                subtitle: Text(
                                  progress.ownedThemes.contains(theme.key)
                                      ? 'Unlocked'
                                      : '${theme.value} coins',
                                  style: const TextStyle(color: Brand.muted),
                                ),
                                trailing: progress.activeTheme == theme.key
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Brand.aqua,
                                      )
                                    : TextButton(
                                        onPressed: () {
                                          if (!progress.unlockTheme(
                                            theme.key,
                                          )) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Not enough coins yet',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          progress.ownedThemes.contains(
                                                theme.key,
                                              )
                                              ? 'USE'
                                              : 'UNLOCK',
                                        ),
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _settings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF211A50),
      builder: (sheet) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: progress,
            builder: (_, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GAME SETTINGS',
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                _toggle(
                  'Sound effects',
                  Icons.volume_up_rounded,
                  progress.soundEnabled,
                  (v) => progress.updateSettings(sound: v),
                ),
                _toggle(
                  'Ambient music',
                  Icons.music_note_rounded,
                  progress.musicEnabled,
                  (v) {
                    progress.updateSettings(music: v);
                    unawaited(audio.syncMusic());
                  },
                ),
                _toggle(
                  'Haptic feedback',
                  Icons.vibration_rounded,
                  progress.hapticsEnabled,
                  (v) => progress.updateSettings(haptics: v),
                ),
                _toggle(
                  'Reduced motion',
                  Icons.accessibility_new_rounded,
                  progress.reducedMotion,
                  (v) => progress.updateSettings(motion: v),
                ),
                const Text(
                  'Progress and preferences are saved on this device.',
                  style: TextStyle(color: Brand.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> change,
  ) => SwitchListTile.adaptive(
    title: Text(title, style: const TextStyle(color: Brand.white)),
    secondary: Icon(icon, color: Brand.aqua),
    value: value,
    onChanged: change,
  );

  void _contact(BuildContext context) {
    unawaited(audio.tap());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContactScreen(theme: progress.activeTheme),
      ),
    );
  }

  void _help(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('HOW TO PLAY'),
        content: const Text(
          'Tap one bottle, then another to pour into an empty bottle or onto the same color. Use HINT for a move from the current board. A bonus bottle can be purchased once per puzzle. Earn stars, claim daily rewards and unlock themes!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: progress,
    builder: (context, _) => Scaffold(
      body: GradientBackground(
        theme: progress.activeTheme,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    minHeight:
                        constraints.maxHeight.isFinite &&
                            constraints.maxHeight > 38.0
                        ? constraints.maxHeight - 38.0
                        : 0.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              'assets/images/game_icon_1024.png',
                              width: 44,
                              height: 44,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ARKTECH',
                                  style: TextStyle(
                                    color: Brand.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'SOLUTIONS • GAMES',
                                  style: TextStyle(
                                    color: Brand.muted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            key: const Key('contact-shortcut'),
                            tooltip: 'Contact Us',
                            onPressed: () => _contact(context),
                            icon: const Icon(
                              Icons.support_agent_rounded,
                              color: Brand.aqua,
                            ),
                          ),
                          IconButton(
                            key: const Key('settings-button'),
                            tooltip: 'Settings',
                            onPressed: () => _settings(context),
                            icon: const Icon(
                              Icons.settings_rounded,
                              color: Brand.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'SORT • RELAX • MASTER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Brand.aqua,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'COLOR SORT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Brand.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'MASTER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Brand.gold,
                            fontSize: 39,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Brand.panel.withValues(alpha: .85),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'THE RAINBOW LAB',
                              style: TextStyle(
                                color: Brand.muted,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 105,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (final tube in const <List<int>>[
                                    [0, 1, 2, 3],
                                    [1, 3, 0, 2],
                                    [4, 5, 1, 2],
                                    [],
                                  ])
                                    SizedBox(
                                      width: 67,
                                      child: PaintedBottle(
                                        layers: tube,
                                        height: 102,
                                        theme: progress.activeTheme,
                                        reducedMotion: progress.reducedMotion,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _StatChip(
                              icon: Icons.emoji_events_rounded,
                              value:
                                  '${progress.clearedLevels}/${PuzzleLevel.totalLevels}',
                              caption: 'COMPLETED',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatChip(
                              icon: Icons.star_rounded,
                              value: '${progress.earnedStars}',
                              caption: 'STARS',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatChip(
                              icon: Icons.toll_rounded,
                              value: '${progress.coins}',
                              caption: 'COINS',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GradientAction(
                        key: const Key('play-now'),
                        label: progress.clearedLevels == 0
                            ? 'PLAY NOW'
                            : 'CONTINUE',
                        icon: Icons.play_arrow_rounded,
                        onTap: () => _play(context, progress.resumeLevel),
                      ),
                      const SizedBox(height: 9),
                      GradientAction(
                        label: 'CHOOSE LEVEL',
                        icon: Icons.grid_view_rounded,
                        secondary: true,
                        onTap: () => _chooseLevel(context),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: _MenuButton(
                              label: 'DAILY',
                              icon: Icons.card_giftcard,
                              onTap: () => _daily(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MenuButton(
                              label: 'AWARDS',
                              icon: Icons.emoji_events,
                              onTap: () => _achievements(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MenuButton(
                              label: 'THEMES',
                              icon: Icons.palette,
                              onTap: () => _themes(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        key: const Key('contact-us'),
                        onPressed: () => _contact(context),
                        icon: const Icon(Icons.support_agent_rounded, size: 18),
                        label: const Text(
                          'CONTACT US',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Brand.white,
                          backgroundColor: Brand.panel,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextButton.icon(
                        onPressed: () => _help(context),
                        icon: const Icon(Icons.help_outline),
                        label: const Text('HOW TO PLAY'),
                        style: TextButton.styleFrom(
                          foregroundColor: Brand.muted,
                        ),
                      ),
                      const Text(
                        '150 VERIFIED LEVELS  •  OFFLINE  •  AUTO-SAVE',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Brand.muted, fontSize: 9),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Powered by ARKTECH SOLUTIONS',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.caption,
  });
  final IconData icon;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: Brand.gold),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Brand.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(caption, style: const TextStyle(color: Brand.muted, fontSize: 9)),
      ],
    ),
  );
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
      foregroundColor: Brand.white,
      backgroundColor: Brand.panel,
      side: const BorderSide(color: Colors.white24),
    ),
    icon: Icon(icon, size: 16),
    label: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
