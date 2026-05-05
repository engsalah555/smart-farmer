import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/ai/services/ai_service.dart';
import '../../features/ai/services/grok_service.dart';
import '../../features/ai/services/plant_diagnosis_service.dart';
import '../../features/community/services/community_service.dart';
import '../../features/crops/services/crops_service.dart';
import '../../features/iot/services/iot_service.dart';
import '../../features/iot/services/firebase_iot_service.dart';

import '../../features/home/services/home_service.dart';
import '../../features/marketplace/services/marketplace_service.dart';
import '../../features/marketplace/services/seller_service.dart';
import '../constants.dart';
import 'auth_service.dart';
import 'error_interceptor.dart';
import 'farm_service.dart';
import 'notification_service.dart';
import 'persistence_service.dart';
import 'hive_persistence_service.dart';

import 'weather_service.dart';
import 'update_service.dart';
import 'admin_service.dart';
import 'verification_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Persistence Service (Registered early)
  final persistence = HivePersistenceService();
  await persistence.init();
  locator.registerSingleton<PersistenceService>(persistence);

  // Shared Preferences (Registered first because others might need it)
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  // Dio instance with Interceptor
  locator.registerLazySingleton<Dio>(() {
    String baseUrl = AppConstants.apiBaseUrl;
    
    // Ensure we don't have double /api/ or double //
    if (baseUrl.endsWith('/api')) {
      baseUrl = '$baseUrl/';
    } else if (baseUrl.endsWith('/api/')) {
      // already perfect
    } else {
      // Append /api/ correctly
      baseUrl = baseUrl.endsWith('/') ? '${baseUrl}api/' : '$baseUrl/api/';
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Auth Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Optimized: Uses the already registered SharedPreferences instance
          final token = locator<SharedPreferences>().getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // Add Global Error Interceptor
    dio.interceptors.add(GlobalErrorInterceptor());

    // Add Logging Interceptor in Debug Mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
        ),
      );
    }

    return dio;
  });

  // New Specialized Services
  locator.registerLazySingleton<MarketplaceService>(
    () => MarketplaceService(locator<Dio>()),
  );
  locator.registerLazySingleton<SellerService>(
    () => SellerService(locator<Dio>()),
  );
  locator.registerLazySingleton<AIService>(() => AIService(locator<Dio>()));
  locator.registerLazySingleton<NotificationService>(
    () => NotificationService(locator<Dio>()),
  );

  // Auth Service
  final authService = AuthService(locator<Dio>());
  await authService.init();
  locator.registerSingleton<AuthService>(authService);

  // Farm Service (IoT Sensor data)
  locator.registerLazySingleton<FarmService>(() => FarmService());

  // Community Service
  locator.registerLazySingleton<CommunityService>(
    () => CommunityService(locator<Dio>()),
  );

  // Crops Service
  locator.registerLazySingleton<CropsService>(
    () => CropsService(locator<Dio>()),
  );

  // IoT Service
  locator.registerLazySingleton<IotService>(() => IotService(locator<Dio>()));
  locator.registerLazySingleton<FirebaseIotService>(() => FirebaseIotService());


  // Home Service
  locator.registerLazySingleton<HomeService>(() => HomeService(locator<Dio>()));

  // Weather Service
  locator.registerLazySingleton<WeatherService>(() => WeatherService());

  // Update Service
  locator.registerLazySingleton<UpdateService>(() => UpdateService());

  // Grok AI Services (يستبدل Gemini)
  locator.registerLazySingleton<GrokService>(() => GrokService());
  locator.registerLazySingleton<PlantDiagnosisService>(
    () => PlantDiagnosisService(),
  );

  // Admin Service
  locator.registerLazySingleton<AdminService>(
    () => AdminService(locator<Dio>()),
  );

  // Verification Service
  locator.registerLazySingleton<VerificationService>(
    () => VerificationService(locator<Dio>()),
  );
}
