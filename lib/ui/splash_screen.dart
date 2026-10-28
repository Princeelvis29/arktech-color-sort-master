import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_audio.dart';
import '../services/game_progress.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.progress, required this.audio});
  final GameProgress progress;
  final GameAudio audio;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1250), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              HomeScreen(progress: widget.progress, audio: widget.audio),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SizedBox.expand(
      child: Image.asset('assets/images/splash_hero.png', fit: BoxFit.cover),
    ),
  );
}
