import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config.dart';

/// AdMob service — manages banner, interstitial, and rewarded ads.
class AdService {
  static AdService? _instance;
  bool _initialized = false;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  AdService._();

  static AdService get instance {
    _instance ??= AdService._();
    return _instance!;
  }

  bool get isInitialized => _initialized;
  bool get isBannerLoaded => _isBannerLoaded;

  /// Initialize the Mobile Ads SDK. Must be called once at app start.
  Future<bool> init() async {
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      // Pre-load ads
      _loadInterstitialAd();
      _loadRewardedAd();
      return true;
    } catch (e) {
      debugPrint('AdService init error: $e');
      _initialized = false;
      return false;
    }
  }

  // ─── Banner Ad ──────────────────────────────────────────────────────

  /// Load a banner ad and return a widget to display it.
  Widget getBannerWidget() {
    if (!_initialized) return const SizedBox(height: 50);

    _bannerAd ??= BannerAd(
      adUnitId: GameConfig.bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
        },
      ),
    )..load();

    return StatefulBuilder(
      builder: (context, setState) {
        if (_bannerAd == null) return const SizedBox(height: 50);
        return Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }

  /// Dispose and reload banner for fresh screens.
  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
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
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              _loadInterstitialAd(); // Pre-load next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: $error');
          _isInterstitialLoaded = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  /// Show an interstitial ad. Returns true if shown.
  Future<bool> showInterstitialAd() async {
    if (!_initialized || !_isInterstitialLoaded || _interstitialAd == null) {
      return false;
    }
    await _interstitialAd!.show();
    return true;
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
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed: $error');
          _isRewardedLoaded = false;
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  /// Show a rewarded ad. Returns true if the user watched it completely.
  Future<bool> showRewardedAd() async {
    if (!_initialized || !_isRewardedLoaded || _rewardedAd == null) {
      return false;
    }

    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        _loadRewardedAd(); // Pre-load next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
      },
    );

    // Wait a moment for callback
    await Future.delayed(const Duration(milliseconds: 500));
    return rewarded;
  }

  /// Show a rewarded ad for hint. Returns true if hint should be granted.
  Future<bool> showHintAd() async => showRewardedAd();

  /// Show a rewarded ad for extra moves. Returns true if granted.
  Future<bool> showExtraMovesAd() async => showRewardedAd();

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
