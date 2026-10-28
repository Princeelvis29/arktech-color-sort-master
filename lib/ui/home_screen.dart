import 'dart:async';
import 'package:flutter/material.dart';
import '../game/puzzle_level.dart';
import '../services/game_audio.dart';
import '../services/game_progress.dart';
import 'brand_theme.dart';
import 'game_screen.dart';
import 'painted_bottle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.progress, required this.audio});
  final GameProgress progress;
  final GameAudio audio;

  void _play(BuildContext context, int index) {
    if (!progress.isUnlocked(index)) return;
    unawaited(audio.tap());
    unawaited(audio.syncMusic());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            GameScreen(levelIndex: index, progress: progress, audio: audio),
      ),
    );
  }

  void _chooseLevel(BuildContext context) {
    unawaited(audio.tap());
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
          heightFactor: .7,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
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
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded, color: Brand.white),
                    ),
                  ],
                ),
                const Text(
                  'Finish levels to unlock more colorful challenges',
                  style: TextStyle(color: Brand.muted, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (_, _) => GridView.builder(
                      itemCount: PuzzleLevel.demo.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 92,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: .95,
                          ),
                      itemBuilder: (_, i) {
                        final unlocked = progress.isUnlocked(i);
                        final stars = progress.starsFor(i);
                        return OutlinedButton(
                          key: Key('level-${i + 1}'),
                          onPressed: unlocked
                              ? () {
                                  Navigator.pop(sheetContext);
                                  _play(context, i);
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(5),
                            backgroundColor: unlocked
                                ? Brand.panel
                                : Brand.navy,
                            side: BorderSide(
                              color: unlocked ? Brand.aqua : Colors.white24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              unlocked
                                  ? Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Brand.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.lock_rounded,
                                      color: Brand.muted,
                                      size: 19,
                                    ),
                              const SizedBox(height: 3),
                              Text(
                                stars == 0
                                    ? (unlocked ? 'READY' : 'LOCKED')
                                    : List.filled(stars, '★').join(),
                                style: TextStyle(
                                  color: stars > 0 ? Brand.gold : Brand.muted,
                                  fontSize: 10,
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
          ),
        ),
      ),
    );
  }

  void _settings(BuildContext context) {
    unawaited(audio.tap());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF211A50),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          child: AnimatedBuilder(
            animation: progress,
            builder: (_, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'GAME SETTINGS',
                        style: TextStyle(
                          color: Brand.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded, color: Brand.white),
                    ),
                  ],
                ),
                _toggle(
                  'Sound effects',
                  Icons.volume_up_rounded,
                  progress.soundEnabled,
                  (v) {
                    progress.updateSettings(sound: v);
                    if (v) unawaited(audio.tap());
                  },
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
                const SizedBox(height: 12),
                const Text(
                  'Progress and preferences are saved on this device.',
                  style: TextStyle(color: Brand.muted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle(
    String text,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      title: Text(
        text,
        style: const TextStyle(color: Brand.white, fontWeight: FontWeight.w700),
      ),
      secondary: Icon(icon, color: Brand.aqua),
      activeTrackColor: Brand.purple,
      value: value,
      onChanged: onChanged,
    );
  }

  void _howToPlay(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('HOW TO PLAY'),
        content: const Text(
          'Tap a bottle to select it, then tap an empty bottle or one with the same top color. Sort each color into its own complete bottle. Undo, Restart, and automatic progress saving are available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('LET\'S PLAY'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(19, 12, 19, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 510,
                      minHeight: constraints.maxHeight - 36,
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
                                width: 46,
                                height: 46,
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
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    'SOLUTIONS • GAMES',
                                    style: TextStyle(
                                      color: Brand.muted,
                                      fontSize: 10,
                                      letterSpacing: .7,
                                    ),
                                  ),
                                ],
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
                        const SizedBox(height: 20),
                        const Text(
                          'SORT • RELAX • MASTER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Brand.aqua,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'COLOR SORT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Brand.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 42,
                              letterSpacing: 1,
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
                              fontWeight: FontWeight.w900,
                              fontSize: 41,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.fromLTRB(7, 17, 7, 17),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                Brand.panel.withValues(alpha: .89),
                                Brand.navy,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .2),
                            ),
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
                              const SizedBox(height: 10),
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SizedBox(
                                  width: 276,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      PaintedBottle(
                                        layers: [0, 1, 2, 3],
                                        height: 117,
                                      ),
                                      PaintedBottle(
                                        layers: [1, 3, 0, 2],
                                        height: 139,
                                      ),
                                      PaintedBottle(
                                        layers: [2, 0, 3, 1],
                                        height: 117,
                                      ),
                                      PaintedBottle(layers: [], height: 117),
                                    ],
                                  ),
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
                                value: '${progress.clearedLevels}/10',
                                caption: 'COMPLETED',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatChip(
                                icon: Icons.star_rounded,
                                value: '${progress.earnedStars}',
                                caption: 'STARS',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatChip(
                                icon: Icons.toll_rounded,
                                value: '${progress.coins}',
                                caption: 'COINS',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GradientAction(
                          key: const Key('play-now'),
                          label: progress.clearedLevels == 0
                              ? 'PLAY NOW'
                              : 'CONTINUE',
                          icon: Icons.play_arrow_rounded,
                          onTap: () => _play(context, progress.resumeLevel),
                        ),
                        const SizedBox(height: 10),
                        GradientAction(
                          label: 'CHOOSE LEVEL',
                          icon: Icons.grid_view_rounded,
                          secondary: true,
                          onTap: () => _chooseLevel(context),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _howToPlay(context),
                          icon: const Icon(Icons.help_outline_rounded),
                          label: const Text('HOW TO PLAY'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Brand.white,
                            minimumSize: const Size.fromHeight(46),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          '10 CURATED LEVELS  •  OFFLINE  •  AUTO-SAVE',
                          style: TextStyle(
                            color: Brand.muted,
                            fontSize: 9,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Powered by ARKTECH SOLUTIONS',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                          textAlign: TextAlign.center,
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Brand.gold, size: 17),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Brand.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            style: const TextStyle(color: Brand.muted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
