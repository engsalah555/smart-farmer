import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/locator.dart';
import 'core/theme/app_theme.dart';
import 'features/community/providers/post_provider.dart';
import 'features/community/providers/comment_provider.dart';
import 'features/crops/providers/crops_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/marketplace/providers/cart_provider.dart';
import 'features/marketplace/providers/marketplace_provider.dart';
import 'features/marketplace/providers/seller_provider.dart';
import 'features/notifications/providers/notifications_provider.dart';
import 'features/iot/providers/iot_provider.dart';
import 'core/providers/admin_provider.dart';
import 'core/routes/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      debugPrint('Flutter Error: ${details.exception}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return true;
  };

  // Use edgeToEdge so Flutter content extends behind system bars without hiding them.
  // This prevents the black screen when returning from another app.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await Hive.openBox('offline_cache');

  await setupLocator();

  final settingsProvider = SettingsProvider();
  settingsProvider.loadMetadata();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (_) {
            final auth = AuthProvider(locator())..init();
            // Inject into router redirect guard so it can skip SplashScreen
            // when the OS restores the app after a process death.
            AppRouter.setAuthProvider(auth);
            return auth;
          },
        ),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => SellerProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider(locator())),
        ChangeNotifierProvider(create: (_) => CommentProvider(locator())),
        ChangeNotifierProvider(create: (_) => CropsProvider(locator())),
        ChangeNotifierProvider(create: (_) => IotProvider(locator())),
        ChangeNotifierProvider(create: (_) => AdminProvider(locator())),
      ],
      child: const SmartFarmApp(),
    ),
  );
}

class SmartFarmApp extends StatefulWidget {
  const SmartFarmApp({super.key});

  @override
  State<SmartFarmApp> createState() => _SmartFarmAppState();
}

class _SmartFarmAppState extends State<SmartFarmApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-apply system UI mode when app resumes from background
    // to prevent black screen after switching back from another app.
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppProvider, ThemeMode>(
      (p) => p.themeMode,
    );

    return MaterialApp.router(
      title: 'Smart Farm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
    );
  }
}
