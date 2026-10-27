import 'package:flutter/material.dart';
import '../game/puzzle_level.dart';
import 'brand_theme.dart';
import 'game_screen.dart';
import 'painted_bottle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _play(BuildContext context, int index) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GameScreen(levelIndex: index)));
  }

  void _chooseLevel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF21194C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 25),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CHOOSE A LEVEL', style: TextStyle(color: Brand.white, fontWeight: FontWeight.w900, fontSize: 23)),
            const SizedBox(height: 6),
            const Text('10 playable prototype levels • Progress saving comes next',
                style: TextStyle(color: Brand.muted, fontSize: 12)),
            const SizedBox(height: 20),
            Wrap(spacing: 10, runSpacing: 10, children: List.generate(PuzzleLevel.demo.length, (i) {
              return SizedBox(width: 60, height: 56, child: OutlinedButton(
                key: Key('level-${i + 1}'),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: Brand.white,
                  side: BorderSide(color: (i < 5 ? Brand.aqua : Brand.gold).withValues(alpha: .7)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _play(context, i);
                },
                child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ));
            })),
          ]),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog<void>(context: context, builder: (_) => AlertDialog(
      title: const Text('How to Play'),
      content: const Text('Tap a bottle to select its top color. Tap another bottle to pour. You can pour into an empty bottle or onto the same color only. Sort every color into a full bottle to win! Undo and Restart are available.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('GOT IT'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(child: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Container(width: 46, height: 46,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Brand.aqua, Brand.purple]), borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 30)),
                  const SizedBox(width: 10),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ARKTECH', style: TextStyle(color: Brand.white, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    Text('SOLUTIONS  •  GAMES', style: TextStyle(color: Brand.muted, fontSize: 9, letterSpacing: 1.2)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .09), borderRadius: BorderRadius.circular(15)),
                    child: const Row(children: [Icon(Icons.stars_rounded, color: Brand.gold, size: 20), SizedBox(width: 5),
                      Text('0', style: TextStyle(color: Brand.white, fontWeight: FontWeight.bold))])),
                ]),
                const SizedBox(height: 28),
                const Text('WELCOME TO', textAlign: TextAlign.center,
                  style: TextStyle(color: Brand.aqua, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const SizedBox(height: 7),
                const FittedBox(fit: BoxFit.scaleDown, child: Text('COLOR SORT', textAlign: TextAlign.center,
                  style: TextStyle(color: Brand.white, fontSize: 41, fontWeight: FontWeight.w900, letterSpacing: 2))),
                const FittedBox(fit: BoxFit.scaleDown, child: Text('MASTER', textAlign: TextAlign.center,
                  style: TextStyle(color: Brand.gold, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 5))),
                const SizedBox(height: 7),
                const Text('SORT THE COLORS. MASTER THE CHALLENGE.', textAlign: TextAlign.center,
                  style: TextStyle(color: Brand.muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 19),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: .17)),
                    gradient: LinearGradient(colors: [Brand.panel.withValues(alpha: .70), Brand.navy.withValues(alpha: .65)])),
                  child: Column(children: [
                    const Text('A RAINBOW IN EVERY BOTTLE', style: TextStyle(color: Brand.muted, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    const FittedBox(fit: BoxFit.scaleDown, child: SizedBox(width: 290,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        PaintedBottle(layers: [0, 1, 2, 3], height: 131),
                        PaintedBottle(layers: [1, 3, 0, 2], height: 148),
                        PaintedBottle(layers: [2, 0, 3, 1], height: 131),
                        PaintedBottle(layers: [], height: 131),
                      ]),
                    )),
                  ]),
                ),
                const SizedBox(height: 19),
                GradientAction(label: 'PLAY NOW', icon: Icons.play_arrow_rounded, onTap: () => _play(context, 0)),
                const SizedBox(height: 12),
                GradientAction(label: 'CHOOSE LEVEL', icon: Icons.grid_view_rounded, secondary: true, onTap: () => _chooseLevel(context)),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: () => _showHowToPlay(context),
                  style: OutlinedButton.styleFrom(foregroundColor: Brand.white, side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  icon: const Icon(Icons.help_outline_rounded), label: const Text('HOW TO PLAY')),
                const SizedBox(height: 12),
                const Text('PROTOTYPE  •  10 VERIFIED PUZZLES  •  OFFLINE', textAlign: TextAlign.center,
                  style: TextStyle(color: Brand.muted, fontSize: 9, letterSpacing: 1.0)),
                const SizedBox(height: 8),
                const Text('Powered by ARKTECH SOLUTIONS', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 10)),
              ]),
            ),
          ),
        );
      }))),
    );
  }
}
