import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/services/cache_service.dart';
import 'core/services/config_service.dart';
import 'core/services/ads_service.dart';
import 'repositories/pack_repository.dart';
import 'repositories/card_repository.dart';

import 'features/game/game_provider.dart';
import 'features/home/home_screen.dart';
import 'features/game/game_screen.dart';
import 'features/settings/settings_screen.dart';

const int _kImageCacheMaxSize = 150;        // max decoded image count
const int _kImageCacheMaxBytes = 100 << 20; // 100 MB — keeps RSS low on mid-range devices

void _tuneImageCache() {
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSize = _kImageCacheMaxSize;
  cache.maximumSizeBytes = _kImageCacheMaxBytes;
}

void _configureSystemUI() {
  // Keep status/nav bar transparent; let content paint edge-to-edge.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  // Portrait only — prevents unnecessary layout recalculations on rotate.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _tuneImageCache();
  _configureSystemUI();

  await dotenv.load(fileName: '.env');
  await CacheService.instance.init();

  final versionChanged = await ConfigService.instance.initialize();

  if (versionChanged) {
    await PackRepository.instance.getPacks(forceRefresh: true);
    await CardRepository.instance.getCards(forceRefresh: true);
  }

  await AdsService.instance.initialize();

  runApp(const ChallengeCardsApp());
}

class ChallengeCardsApp extends StatelessWidget {
  const ChallengeCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Challenge Cards',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF4D8D),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFFFF0F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Color(0xFF2D1B4E),
          ),
        ),
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (_) => const HomeScreen(),
          GameScreen.routeName: (_) => const GameScreen(),
          SettingsScreen.routeName: (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
