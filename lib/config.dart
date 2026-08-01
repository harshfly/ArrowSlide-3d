import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ArrowSlide 3D — Single Configuration File
/// ═══════════════════════════════════════════════════════════════════════════
class GameConfig {
  GameConfig._();

  // ─── App Info ──────────────────────────────────────────────────────────
  static const String gameName = 'ArrowSlide 3D';
  static const String gameTagline = 'Slide. Think. Escape.';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String developerName = 'ArrowSlide Studios';
  static const String copyright = '© 2026 ArrowSlide 3D. All rights reserved.';
  static const String gameDescription =
      'A premium 3D arrow puzzle game. '
      'Slide the glossy arrow cubes, solve the puzzles, and let every arrow escape!';

  // ─── AdMob IDs (Google Test Ad Unit IDs) ──────────────────────────────
  static const String admobAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String bannerAdId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdId = 'ca-app-pub-3940256099942544/5224354917';

  // ─── Ad Behavior ──────────────────────────────────────────────────────
  static const int interstitialFrequency = 3;  // Show interstitial every N completed levels
  static const int retryAdFrequency = 2;       // Show interstitial every N retries
  static const bool hintRequiresAd = true;     // Hints ONLY available after watching rewarded ad
  static const bool showBannerOnHome = true;
  static const bool showBannerOnLevelSelect = true;
  static const bool showBannerOnGameplay = false;
  static const bool showBannerOnVictory = true;

  // ─── Levels ───────────────────────────────────────────────────────────
  static const int totalLevels = 200;
  static const int levelsPerChapter = 50;
  static const int chaptersCount = 4;
  static const List<String> chapterNames = ['The Basics', 'Intermediate', 'Advanced', 'Expert'];
  static const List<String> difficultyLabels = ['Easy', 'Medium', 'Hard', 'Expert'];
  static const int initialUnlockedLevels = 1;

  // Background & Grid
  static const Color background = Color(0xFFFCFBF8);
  static const Color backgroundDark = Color(0xFFFCFBF8);
  static const Color backgroundLight = Color(0xFFFCFBF8);
  static const Color dottedGrid = Color(0xFFE9E6E0);

  // Surface & Cards
  static const Color surface = Colors.white;
  static const Color cardColor = Colors.white; 
  static const Color gridColor = Colors.transparent;
  static const Color surfaceLight = Colors.white;

  // ─── Brand Palette (Exact Claymorphism Tokens) ────────────────────────────────────────
  static const Color primary = Color(0xFF4FA2FF);       // Play Blue (#4FA2FF -> #2E7CF6)
  static const Color primaryDepth = Color(0xFF2E7CF6);  
  
  static const Color secondary = Color(0xFF38D99D);     // Green (#38D99D -> #23C182)
  static const Color secondaryDepth = Color(0xFF23C182);
  
  static const Color accent = Color(0xFFF7B521);        // Orange (#F7B521 -> #D99110)
  static const Color accentDepth = Color(0xFFD99110);   
  
  static const Color danger = Color(0xFFFF7A8B);        // Coral (#FF7A8B -> #FF566C)
  static const Color dangerDepth = Color(0xFFFF566C);   

  static const Color error = Color(0xFFFF7A8B);
  static const Color orange = Color(0xFFF7B521);
  static const Color purple = Color(0xFFD355FF);        
  static const Color purpleDepth = Color(0xFFA033D2);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2430);      
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textColor = Color(0xFF1F2430);
  static const Color textMuted = Color(0xFFC7C7C7); // Disabled

  // Status & Rewards
  static const Color warning = accent;
  static const Color success = secondary;
  static const Color coinsColor = accent;       
  static const Color starsColor = accent;       

  // ─── Arrow Cube Color Palette ──────────────────────────────────────────
  static const Color cubeBlue = Color(0xFF4A95FF);
  static const Color cubeBlueSide = Color(0xFF2F6ED9);
  
  static const Color cubeRed = Color(0xFFFF6268);
  static const Color cubeRedSide = Color(0xFFD9444C);
  
  static const Color cubeGreen = Color(0xFF38D99D);
  static const Color cubeGreenSide = Color(0xFF20B97D);
  
  static const Color cubeYellow = Color(0xFFF7B521);
  static const Color cubeYellowSide = Color(0xFFD99110);
  
  static const Color cubePurple = purple;
  static const Color cubePurpleSide = purpleDepth;
  
  static const Color cubeOrange = accent;
  static const Color cubeOrangeSide = accentDepth;

  // Block color mappings
  static const Color playerBlockColor = cubeBlue;
  static const Color playerBlockSide = cubeBlueSide;
  static const Color playerBlockTop = cubeBlue;
  static const Color obstacleBlockColor = cubeRed;
  static const Color obstacleBlockSide = cubeRedSide;
  static const Color obstacleBlockTop = cubeRed;
  static const Color keyBlockColor = cubeYellow;
  static const Color keyBlockSide = cubeYellowSide;
  static const Color keyBlockTop = cubeYellow;
  static const Color rotBlockColor = cubeGreen;
  static const Color rotBlockSide = cubeGreenSide;
  static const Color rotBlockTop = cubeGreen;
  static const Color genericBlockColor = cubePurple;
  static const Color genericBlockSide = cubePurpleSide;
  static const Color genericBlockTop = cubePurple;

  static const List<Color> chapterColors = [secondary, accent, danger, primary];

  // Tile colors
  static const Color wallColor = Colors.transparent;
  static const Color floorColor = Colors.transparent;
  static const Color iceColor = Color(0xFF38BDF8);
  static const Color exitColor = Color(0xFF10B981);
  static const Color teleporterColor = Color(0xFF38BDF8);
  static const Color portalColor = Color(0xFFCC5DE8);
  static const Color lockColor = Color(0xFFF59E0B);
  static const Color switchColor = Color(0xFF4F46E5);

  // ─── Coins & Rewards ──────────────────────────────────────────────────
  static const int initialCoins = 500;
  static const int initialHints = 3;
  static const int coinsPerStar = 10;
  static const int levelCompleteBaseCoins = 20;
  static const int hintCoinCost = 0;
  static const int hintRewardFromAd = 1;
  static const int extraMovesFromAd = 5;

  // ─── Daily Reward Cycle ───────────────────────────────────────────────
  static const int dailyRewardCycleDays = 7;
  static const List<Map<String, dynamic>> dailyRewards = [
    {'coins': 50, 'hints': 0},
    {'coins': 75, 'hints': 1},
    {'coins': 100, 'hints': 0},
    {'coins': 125, 'hints': 1},
    {'coins': 150, 'hints': 0},
    {'coins': 200, 'hints': 2},
    {'coins': 300, 'hints': 3},
  ];

  // ─── Animations ───────────────────────────────────────────────────────
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration blockSlideDuration = Duration(milliseconds: 160);
  static const Duration screenTransitionDuration = Duration(milliseconds: 300);
  static const Duration staggerAnimationDuration = Duration(milliseconds: 1200);
  static const Duration starAnimationDuration = Duration(milliseconds: 1500);
  static const Duration particleDuration = Duration(milliseconds: 800);
  static const Duration buttonPressDuration = Duration(milliseconds: 150);

  static const Curve blockSlideCurve = Curves.easeOutQuad;
  static const Curve screenTransitionCurve = Curves.easeOut;

  // ─── Gameplay ─────────────────────────────────────────────────────────
  static const int maxUndos = 10;
  static const int threeStarThreshold = 0;
  static const int twoStarThreshold = 2;

  // ─── Audio Settings ───────────────────────────────────────────────────
  static const double defaultMusicVolume = 0.5;
  static const double defaultSfxVolume = 0.8;
  static const bool defaultMusicEnabled = true;
  static const bool defaultSoundEnabled = true;
  static const bool defaultVibrationEnabled = true;

  // ─── UI Sizing (8pt Grid System, Rounded Corners 18–24px) ─────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0; 
  static const double radiusLg = 24.0; 
  static const double radiusXl = 28.0;

  static const double blockSizeRatio = 0.88;
  static const double minCellSize = 44.0;
  static const double maxCellSize = 72.0;
  static const int levelGridColumns = 5;
}
