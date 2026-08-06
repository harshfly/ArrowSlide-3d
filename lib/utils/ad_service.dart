import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config.dart';

/// AdMob service — manages banner, interstitial, and rewarded ads.
///
/// Features:
/// - Pre-loads interstitial and rewarded ads at init
/// - Exponential backoff on load failures (30s → 60s → 120s, max 5min)
/// - Graceful failure handling — never blocks UI
/// - Debug-only logging
class AdService {
  static AdService? _instance;
  bool _initialized = false;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  int _interstitialRetryCount = 0;
  int _rewardedRetryCount = 0;
  static const int _maxRetries = 5;

  AdService._();

  static AdService get instance {
    _instance ??= AdService._();
    return _instance!;
  }

  bool get isInitialized => _initialized;

  /// Initialize the Mobile Ads SDK. Must be called once at app start.
  Future<bool> init() async {
    if (_initialized) return true;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      // Pre-load ads in background
      _loadInterstitialAd();
      _loadRewardedAd();
      return true;
    } catch (e) {
      _debugLog('AdService init error: $e');
      _initialized = false;
      return false;
    }
  }

  // ─── Banner Ad ──────────────────────────────────────────────────────

  /// Returns a banner ad widget. Safe to call even if SDK not initialized.
  Widget getBannerWidget() {
    if (!_initialized) return const SizedBox(height: 50);
    return const _BannerAdWidget();
  }

  // ─── Interstitial Ad ────────────────────────────────────────────────

  void _loadInterstitialAd() {
    if (!_initialized) return;
    InterstitialAd.load(
      adUnitId: GameConfig.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          _interstitialRetryCount = 0;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _debugLog('Interstitial show failed: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _debugLog('Interstitial load failed: $error');
          _isInterstitialLoaded = false;
          _retryWithBackoff(
            _loadInterstitialAd,
            _interstitialRetryCount++,
          );
        },
      ),
    );
  }

  /// Show an interstitial ad. Returns true if shown, false otherwise.
  /// Never blocks UI — returns immediately if ad not ready.
  Future<bool> showInterstitialAd() async {
    if (!_initialized || !_isInterstitialLoaded || _interstitialAd == null) {
      return false;
    }
    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      _debugLog('Interstitial show error: $e');
      return false;
    }
  }

  // ─── Rewarded Ad ────────────────────────────────────────────────────

  void _loadRewardedAd() {
    if (!_initialized) return;
    RewardedAd.load(
      adUnitId: GameConfig.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          _rewardedRetryCount = 0;
        },
        onAdFailedToLoad: (error) {
          _debugLog('Rewarded load failed: $error');
          _isRewardedLoaded = false;
          _retryWithBackoff(
            _loadRewardedAd,
            _rewardedRetryCount++,
          );
        },
      ),
    );
  }

  /// Show a rewarded ad. Returns true if the user watched it completely.
  Future<bool> showRewardedAd() async {
    if (!_initialized || !_isRewardedLoaded || _rewardedAd == null) {
      return false;
    }

    final completer = Completer<bool>();
    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _debugLog('Rewarded show failed: $error');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewarded = true;
        },
      );
    } catch (e) {
      _debugLog('Rewarded show error: $e');
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  /// Show a rewarded ad for hint. Returns true if hint should be granted.
  Future<bool> showHintAd() async => showRewardedAd();

  /// Show a rewarded ad for extra moves. Returns true if granted.
  Future<bool> showExtraMovesAd() async => showRewardedAd();

  /// Retry with exponential backoff: 30s, 60s, 120s, 240s, 300s (max).
  void _retryWithBackoff(VoidCallback loader, int retryCount) {
    if (retryCount >= _maxRetries) {
      _debugLog('Max ad retry count reached, stopping retries');
      return;
    }
    final delay = Duration(
      seconds: (30 * (1 << retryCount)).clamp(30, 300),
    );
    Future.delayed(delay, loader);
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _isInterstitialLoaded = false;
    _isRewardedLoaded = false;
  }

  static void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[AdService] $message');
    }
  }
}

/// Self-contained banner ad widget with proper lifecycle management.
class _BannerAdWidget extends StatefulWidget {
  const _BannerAdWidget();

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: GameConfig.bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint('[AdService] Banner load failed: $error');
          }
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
