import 'package:flutter/material.dart';
import '../config.dart';
import '../screens/splash_screen.dart';
import '../screens/no_internet_screen.dart';
import '../screens/home_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/gameplay_screen.dart';
import '../screens/pause_screen.dart';
import '../screens/victory_screen.dart';
import '../screens/failed_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../screens/daily_reward_screen.dart';

/// Centralized route definitions for ArrowSlide 3D.
class AppRouter {
  AppRouter._();

  // ─── Route Names ───────────────────────────────────────────────
  static const String splash = '/';
  static const String noInternet = '/no-internet';
  static const String home = '/home';
  static const String levelSelect = '/level-select';
  static const String gameplay = '/gameplay';
  static const String pause = '/pause';
  static const String victory = '/victory';
  static const String failed = '/failed';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String dailyReward = '/daily-reward';

  // ─── Route Generator ──────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), routeSettings);
      case noInternet:
        return _buildRoute(const NoInternetScreen(), routeSettings);
      case home:
        return _buildRoute(const HomeScreen(), routeSettings);
      case levelSelect:
        return _buildRoute(const LevelSelectScreen(), routeSettings);
      case gameplay:
        final levelId = routeSettings.arguments as int? ?? 1;
        return _buildRoute(GameplayScreen(levelId: levelId), routeSettings);
      case pause:
        return _buildRoute(const PauseScreen(), routeSettings);
      case victory:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _buildRoute(
          VictoryScreen(
            levelId: args['levelId'] as int? ?? 1,
            moves: args['moves'] as int? ?? 0,
            stars: args['stars'] as int? ?? 1,
          ),
          routeSettings,
        );
      case failed:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _buildRoute(
          FailedScreen(
            levelId: args['levelId'] as int? ?? 1,
            moves: args['moves'] as int? ?? 0,
            bestMoves: args['bestMoves'] as int? ?? 0,
          ),
          routeSettings,
        );
      case settings:
        return _buildRoute(const SettingsScreen(), routeSettings);
      case about:
        return _buildRoute(const AboutScreen(), routeSettings);
      case dailyReward:
        return _buildRoute(const DailyRewardScreen(), routeSettings);
      default:
        return _buildRoute(const SplashScreen(), routeSettings);
    }
  }

  /// Flat fade transition — no Material slide or cupertino push.
  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: GameConfig.screenTransitionDuration,
    );
  }
}
