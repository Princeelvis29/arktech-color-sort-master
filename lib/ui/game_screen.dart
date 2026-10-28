import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game/puzzle_controller.dart';
import '../game/puzzle_level.dart';
import '../services/game_audio.dart';
import '../services/game_progress.dart';
import 'brand_theme.dart';
import 'painted_bottle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.levelIndex,
    required this.progress,
    required this.audio,
  });
  final int levelIndex;
  final GameProgress progress;
  final GameAudio audio;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int _index;
  late PuzzleController _controller;
  bool _winShown = false;
  int _reward = 0;
  int _lastSavedMoves = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.levelIndex;
    _createController(_index);
  }

  void _createController(int index) {
    _controller = PuzzleController(PuzzleLevel.demo[index]);
    final saved = widget.progress.sessionFor(index);
    if (saved != null) _controller.restore(saved);
    _lastSavedMoves = _controller.moves;
    _controller.addListener(_refresh);
    if (saved == null || _controller.moves == 0) {
      widget.progress.saveSession(index, _controller.snapshot());
    }
  }

  void _refresh() {
    if (!mounted) return;
    if (_lastSavedMoves != _controller.moves) {
      _lastSavedMoves = _controller.moves;
      if (_controller.isComplete) {
        _reward = widget.progress.finishLevel(_index, _controller.moves);
        unawaited(widget.audio.win());
      } else {
        widget.progress.saveSession(_index, _controller.snapshot());
      }
    }
    setState(() {});
    if (_controller.isComplete && !_winShown) {
      _winShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _presentVictory();
      });
    }
  }

  void _loadLevel(int newIndex) {
    _controller.removeListener(_refresh);
    _controller.dispose();
    setState(() {
      _index = newIndex;
      _winShown = false;
      _reward = 0;
      _createController(_index);
    });
  }

  void _restart() {
    unawaited(widget.audio.tap());
    _winShown = false;
    _controller.restart();
    widget.progress.saveSession(_index, _controller.snapshot());
  }

  void _tapBottle(int i) {
    final poured = _controller.tapBottle(i);
    if (poured && !_controller.isComplete) {
      unawaited(widget.audio.pour());
    } else if (!poured) {
      unawaited(widget.audio.tap());
    }
  }

  void _presentVictory() {
    final current = _index;
    final moves = _controller.moves;
    final stars = widget.progress.starsFor(current);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF271C62),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .82,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Brand.gold,
                  size: 56,
                ),
                const SizedBox(height: 6),
                const Text(
                  'LEVEL COMPLETE!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Brand.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  List.filled(stars, '★').join(),
                  style: const TextStyle(color: Brand.gold, fontSize: 31),
                ),
                Text(
                  'Sorted in $moves moves',
                  style: const TextStyle(color: Brand.muted),
                ),
                if (_reward > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+$_reward COINS',
                    style: const TextStyle(
                      color: Brand.aqua,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                GradientAction(
                  label: current + 1 == PuzzleLevel.demo.length
                      ? 'BACK TO HOME'
                      : 'NEXT LEVEL',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (current + 1 < PuzzleLevel.demo.length) {
                      _loadLevel(current + 1);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _restart();
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('REPLAY LEVEL'),
                  style: TextButton.styleFrom(foregroundColor: Brand.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = PuzzleLevel.demo[_index];
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, bounds) {
              final bottleHeight = bounds.maxWidth < 340
                  ? 112.0
                  : bounds.maxHeight < 700
                  ? 122.0
                  : 145.0;
              final wide = bounds.maxWidth > 520;
              final boardMaxWidth = wide ? 470.0 : bounds.maxWidth - 30;
              final cells = _controller.bottles;
              final cellWidth = math.min((boardMaxWidth - 28) / 3, 135.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 9, 15, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 520,
                      minHeight: bounds.maxHeight - 29,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Back',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Brand.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LEVEL ${level.number.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: Brand.aqua,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    level.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Brand.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .11),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    color: Brand.gold,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_controller.moves}',
                                    style: const TextStyle(
                                      color: Brand.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _controller.isComplete
                              ? 'ALL COLORS SORTED!'
                              : 'Tap a bottle, then tap where to pour',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Brand.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Brand.panel.withValues(alpha: .6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .15),
                            ),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            spacing: 4,
                            runSpacing: 14,
                            children: List.generate(
                              cells.length,
                              (i) => SizedBox(
                                width: cellWidth,
                                child: InkWell(
                                  key: Key('bottle-$i'),
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => _tapBottle(i),
                                  child: Column(
                                    children: [
                                      PaintedBottle(
                                        layers: cells[i],
                                        selected: _controller.selected == i,
                                        height: bottleHeight,
                                        reducedMotion:
                                            widget.progress.reducedMotion,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          color: _controller.selected == i
                                              ? Brand.aqua
                                              : Brand.muted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _ControlButton(
                                label: 'UNDO',
                                icon: Icons.undo_rounded,
                                enabled: _controller.canUndo,
                                onTap: () {
                                  unawaited(widget.audio.tap());
                                  _controller.undo();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ControlButton(
                                label: 'RESTART',
                                icon: Icons.refresh_rounded,
                                enabled: true,
                                onTap: _restart,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Center(
                          child: Text(
                            'SORT EACH BOTTLE INTO ONE COLOR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Brand.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'PROGRESS SAVES AUTOMATICALLY',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              letterSpacing: .7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Brand.white,
        disabledForegroundColor: Brand.muted.withValues(alpha: .45),
        minimumSize: const Size.fromHeight(49),
        side: BorderSide(color: enabled ? Colors.white38 : Colors.white12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
