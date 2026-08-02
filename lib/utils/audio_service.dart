import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config.dart';

/// Audio service — manages SFX playback with proper lifecycle and error handling.
///
/// Uses a single reusable [AudioPlayer] for slide sounds with
/// [PlayerMode.lowLatency], and [SystemSound] fallbacks for simple taps.
class AudioService {
  static AudioService? _instance;

  bool _musicEnabled = GameConfig.defaultMusicEnabled;
  bool _soundEnabled = GameConfig.defaultSoundEnabled;
  bool _initialized = false;
  AudioPlayer? _slidePlayer;
  bool _isSlidePlayerBusy = false;

  AudioService._();

  static AudioService get instance {
    _instance ??= AudioService._();
    return _instance!;
  }

  bool get musicEnabled => _musicEnabled;
  bool get soundEnabled => _soundEnabled;

  /// Initialize audio — call once at app start.
  Future<void> init() async {
    if (_initialized) return;
    try {
      _slidePlayer = AudioPlayer();
      await _slidePlayer!.setPlayerMode(PlayerMode.lowLatency);
      _initialized = true;
    } catch (e) {
      _debugLog('AudioService init error: $e');
      _initialized = true; // Mark initialized anyway, will use SystemSound fallback
    }
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) stopBgMusic();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play the whoosh slide sound with debounce to avoid overlap.
  Future<void> playSlideSound() async {
    if (!_soundEnabled || !_initialized || _isSlidePlayerBusy) return;
    _isSlidePlayerBusy = true;
    try {
      final player = _slidePlayer;
      if (player != null) {
        await player.stop();
        await player.play(
          AssetSource('audio/whoosh-sfx.mp3'),
          mode: PlayerMode.lowLatency,
        );
      }
    } catch (e) {
      _debugLog('Slide sound error: $e');
      // Fallback to system click
      SystemSound.play(SystemSoundType.click);
    } finally {
      _isSlidePlayerBusy = false;
    }
  }

  Future<void> playWinSound() async {
    if (!_soundEnabled || !_initialized) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> playFailSound() async {
    if (!_soundEnabled || !_initialized) return;
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  Future<void> playTap() async {
    if (!_soundEnabled || !_initialized) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> playSlide() => playSlideSound();
  Future<void> playWin() => playWinSound();
  Future<void> playFail() => playFailSound();

  Future<void> startBgMusic() async {}
  Future<void> stopBgMusic() async {}

  /// Properly release audio resources.
  void dispose() {
    stopBgMusic();
    _slidePlayer?.dispose();
    _slidePlayer = null;
    _initialized = false;
  }

  /// Log only in debug mode.
  static void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[AudioService] $message');
    }
  }
}
