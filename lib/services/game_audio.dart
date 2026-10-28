import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'game_progress.dart';

/// Independent effect and music channels. Music follows the app lifecycle.
class GameAudio with WidgetsBindingObserver {
  GameAudio(this.progress) {
    WidgetsBinding.instance.addObserver(this);
  }

  final GameProgress progress;
  final AudioPlayer _effects = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();

  bool _musicRunning = false;
  bool _musicStarting = false;
  bool _inForeground = true;

  Future<void> tap() async {
    if (progress.hapticsEnabled) {
      try {
        await HapticFeedback.selectionClick();
      } catch (_) {}
    }
    await _effect('tap.wav');
  }

  Future<void> pour() async {
    if (progress.hapticsEnabled) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {}
    }
    await _effect('pour.wav');
  }

  Future<void> win() async {
    if (progress.hapticsEnabled) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
    await _effect('win.wav');
  }

  Future<void> _effect(String name) async {
    if (!progress.soundEnabled) return;
    try {
      await _effects.stop();
      await _effects.play(AssetSource('audio/$name'), volume: 0.56);
    } catch (_) {
      // Missing audio device and browser sound restrictions must not block play.
    }
  }

  /// Play original music throughout the game, in a seamless loop.
  /// Chrome and Edge normally require a user gesture before sound can begin.
  Future<void> syncMusic() async {
    if (!progress.musicEnabled) {
      _musicRunning = false;
      try {
        await _music.stop();
      } catch (_) {}
      return;
    }
    if (!_inForeground || _musicRunning || _musicStarting) return;

    _musicStarting = true;
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      if (!_inForeground || !progress.musicEnabled) return;
      await _music.play(
        AssetSource('audio/background_music.wav'),
        volume: 0.21,
      );
      if (!_inForeground || !progress.musicEnabled) {
        await _music.pause();
        return;
      }
      _musicRunning = true;
    } catch (_) {
      // Retry on the next interaction if browser autoplay has been denied.
      _musicRunning = false;
    } finally {
      _musicStarting = false;
    }
  }

  Future<void> _pauseMusic() async {
    _musicRunning = false;
    try {
      await _music.pause();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _inForeground = false;
        unawaited(_pauseMusic());
      case AppLifecycleState.resumed:
        _inForeground = true;
        // Native Android can resume music automatically; browsers may require
        // the user to interact again to regain permission to play audio.
        if (!kIsWeb) unawaited(syncMusic());
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_effects.dispose());
    unawaited(_music.dispose());
  }
}
