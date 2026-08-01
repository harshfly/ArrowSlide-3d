import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config.dart';

/// Audio service — whoosh.mp3 slide sound via audioplayers with SystemSound fallback.
class AudioService {
  static AudioService? _instance;
  bool _musicEnabled = GameConfig.defaultMusicEnabled;
  bool _soundEnabled = GameConfig.defaultSoundEnabled;
  bool _initialized = false;
  AudioPlayer? _slidePlayer;

  AudioService._();

  static AudioService get instance {
    _instance ??= AudioService._();
    return _instance!;
  }

  bool get musicEnabled => _musicEnabled;
  bool get soundEnabled => _soundEnabled;

  Future<void> init() async {
    _initialized = true;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) stopBgMusic();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play the whoosh slide sound
  Future<void> playSlideSound() async {
    if (!_soundEnabled || !_initialized) return;
    try {
      _slidePlayer ??= AudioPlayer();
      await _slidePlayer!.stop();
      await _slidePlayer!.play(AssetSource('audio/whoosh-sfx.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> playWinSound() async {
    if (!_soundEnabled || !_initialized) return;
    SystemSound.play(SystemSoundType.click);
  }

  Future<void> playFailSound() async {
    if (!_soundEnabled || !_initialized) return;
    SystemSound.play(SystemSoundType.alert);
  }

  Future<void> playTap() async {
    if (!_soundEnabled || !_initialized) return;
    SystemSound.play(SystemSoundType.click);
  }

  Future<void> playSlide() => playSlideSound();
  Future<void> playWin() => playWinSound();
  Future<void> playFail() => playFailSound();

  Future<void> startBgMusic() async {}
  Future<void> stopBgMusic() async {}

  void dispose() {
    stopBgMusic();
  }
}
