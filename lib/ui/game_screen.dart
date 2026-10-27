import 'package:flutter/material.dart';
import '../game/puzzle_controller.dart';
import '../game/puzzle_level.dart';
import 'brand_theme.dart';
import 'painted_bottle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelIndex});
  final int levelIndex;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int _index;
  late PuzzleController _controller;
  bool _showWin = false;

  @override
  void initState() {
    super.initState();
    _index = widget.levelIndex;
    _controller = PuzzleController(PuzzleLevel.demo[_index]);
    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (_controller.isComplete) _showWin = true;
    if (mounted) setState(() {});
  }

  void _loadLevel(int index) {
    _controller.removeListener(_refresh);
    _controller.dispose();
    setState(() {
      _index = index;
      _controller = PuzzleController(PuzzleLevel.demo[_index]);
      _showWin = false;
      _controller.addListener(_refresh);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _restart() {
    setState(() => _showWin = false);
    _controller.restart();
  }

  @override
  Widget build(BuildContext context) {
    final level = PuzzleLevel.demo[_index];
    return Scaffold(
      body: GradientBackground(child: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        final boardHeight = constraints.maxHeight < 660 ? 134.0 : 162.0;
        return SingleChildScrollView(child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              IconButton(tooltip: 'Back', onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Brand.white)),
              const SizedBox(width: 5),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('LEVEL ${level.number.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Brand.aqua, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                Text(level.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Brand.white, fontSize: 19, fontWeight: FontWeight.w900)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white.withValues(alpha: .11)),
                child: Row(children: [const Icon(Icons.swipe_rounded, color: Brand.gold, size: 20),
                  const SizedBox(width: 6), Text('${_controller.moves}', style: const TextStyle(color: Brand.white, fontSize: 17, fontWeight: FontWeight.w900))])),
            ]),
            const SizedBox(height: 12),
            Text(_controller.isComplete ? 'ALL COLORS SORTED!' : 'Tap a bottle, then tap where to pour',
              textAlign: TextAlign.center, style: const TextStyle(color: Brand.muted, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 7),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(26),
                color: Brand.panel.withValues(alpha: .51), border: Border.all(color: Colors.white.withValues(alpha: .13))),
              child: LayoutBuilder(builder: (context, boardConstraints) {
                final cells = _controller.bottles;
                final width = boardConstraints.maxWidth / 3;
                return Wrap(alignment: WrapAlignment.center, runAlignment: WrapAlignment.center,
                  spacing: 0, runSpacing: 12,
                  children: List.generate(cells.length, (i) {
                    return SizedBox(width: width, child: InkWell(
                      key: Key('bottle-$i'),
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _controller.tapBottle(i),
                      child: Column(children: [
                        PaintedBottle(layers: cells[i], selected: _controller.selected == i, height: boardHeight),
                        const SizedBox(height: 4),
                        Text('${i + 1}', style: TextStyle(color: _controller.selected == i ? Brand.aqua : Brand.muted,
                          fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ));
                  }),
                );
              }),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _ControlButton(label: 'UNDO', icon: Icons.undo_rounded,
                enabled: _controller.canUndo, onTap: () { _showWin = false; _controller.undo(); })),
              const SizedBox(width: 12),
              Expanded(child: _ControlButton(label: 'RESTART', icon: Icons.refresh_rounded,
                enabled: true, onTap: _restart)),
            ]),
            const SizedBox(height: 16),
            if (_showWin) ...[
              Container(padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(colors: [Color(0xFF5C3696), Color(0xFF263D83)]),
                  border: Border.all(color: Brand.gold.withValues(alpha: .7))),
                child: Column(children: [
                  const Icon(Icons.emoji_events_rounded, color: Brand.gold, size: 45),
                  const Text('LEVEL COMPLETE!', style: TextStyle(color: Brand.white, fontSize: 21, fontWeight: FontWeight.w900)),
                  Text('Finished in ${_controller.moves} moves', style: const TextStyle(color: Brand.muted)),
                  const SizedBox(height: 14),
                  GradientAction(label: _index + 1 == PuzzleLevel.demo.length ? 'BACK TO HOME' : 'NEXT LEVEL',
                    icon: Icons.arrow_forward_rounded,
                    onTap: () {
                      if (_index + 1 < PuzzleLevel.demo.length) {
                        _loadLevel(_index + 1);
                      } else {
                        Navigator.of(context).pop();
                      }
                    }),
                ])),
            ] else ...[
              const Center(child: Text('SORT EACH BOTTLE INTO ONE COLOR',
                style: TextStyle(color: Brand.muted, letterSpacing: 1.5, fontWeight: FontWeight.w700, fontSize: 10))),
            ],
          ]),
        ));
      }))),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.label, required this.icon, required this.enabled, required this.onTap});
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: Brand.white, disabledForegroundColor: Brand.muted.withValues(alpha: .45),
        side: BorderSide(color: enabled ? Colors.white38 : Colors.white12),
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: Icon(icon, size: 21), label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }
}
