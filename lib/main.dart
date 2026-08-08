import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'utils/app_theme.dart';
import 'utils/app_router.dart';
import 'utils/storage_service.dart';
import 'utils/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set system UI styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameConfig.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize essential services before runApp
  final storageService = await StorageService.getInstance();

  // Initialize audio in background (non-blocking)
  AudioService.instance.init();
  // Apply saved audio settings
  AudioService.instance.setMusicEnabled(
    storageService.userData.settings.musicEnabled,
  );
  AudioService.instance.setSoundEnabled(
    storageService.userData.settings.soundEnabled,
  );

  // Disable debug logging in release
  if (!kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(
    Provider<StorageService>.value(
      value: storageService,
      child: const ArrowSlideApp(),
    ),
  );
}

class ArrowSlideApp extends StatelessWidget {
  const ArrowSlideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GameConfig.gameName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
