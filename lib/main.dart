import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'services/game_audio.dart';
import 'services/game_progress.dart';
import 'ui/brand_theme.dart';
import 'ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved game progress and player preferences.
  final progress = await GameProgress.load();

  // Start ARKTECH COLOR SORT MASTER.
  runApp(ArktechColorSortApp(progress: progress));
}

class ArktechColorSortApp extends StatefulWidget {
  const ArktechColorSortApp({super.key, required this.progress});

  final GameProgress progress;

  @override
  State<ArktechColorSortApp> createState() => _ArktechColorSortAppState();
}

class _ArktechColorSortAppState extends State<ArktechColorSortApp> {
  late final GameAudio _audio;

  @override
  void initState() {
    super.initState();

    // Initialize the game's audio service.
    _audio = GameAudio(widget.progress);
    // Native Android can start music at launch. Browsers need a click/tap.
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_audio.syncMusic());
      });
    }
  }

  @override
  void dispose() {
    // Release audio resources when the app closes.
    _audio.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARKTECH COLOR SORT MASTER',

      debugShowCheckedModeBanner: false,
      // A pointer-down event enables audio after a browser user gesture.
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => unawaited(_audio.syncMusic()),
        child: child ?? const SizedBox.shrink(),
      ),

      theme: ThemeData(
        useMaterial3: true,

        // Use the locally bundled Roboto font.
        fontFamily: 'Roboto',

        // Preserve the official ARKTECH game colors.
        scaffoldBackgroundColor: Brand.navy,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Brand.purple,
          brightness: Brightness.dark,
        ),
      ),

      // Launch the branded splash screen.
      home: SplashScreen(progress: widget.progress, audio: _audio),
    );
  }
}
