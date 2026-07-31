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
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameConfig.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.getInstance();
  AudioService.instance.init();

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
