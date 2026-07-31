import 'package:flutter/services.dart';
import '../config.dart';

/// Audio service — whoosh.mp3 slide sound via SystemSound fallback.
/// For real audio playback, audioplayers would be added when path-space issues are resolved.
class AudioService {
  static AudioService? _instance;
  bool _musicEnabled = GameConfig.defaultMusicEnabled;
  bool _soundEnabled = GameConfig.defaultSoundEnabled;
  bool _initialized = false;

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
    // Fallback: SystemSound click
    SystemSound.play(SystemSoundType.click);
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
