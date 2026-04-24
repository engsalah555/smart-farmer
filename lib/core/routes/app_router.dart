import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/language_selection_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/crops/screens/crops_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/ai/screens/disease_detection_screen.dart';
import '../../features/marketplace/screens/add_product_screen.dart';
import '../models/product_model.dart';
import '../../features/marketplace/screens/store_settings_screen.dart';
import '../../features/marketplace/screens/seller_orders_screen.dart';
import '../../features/community/screens/forum_screen.dart';
import '../../features/community/screens/create_post_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/marketplace/screens/cart_screen.dart';
import '../../features/marketplace/screens/store_details_screen.dart';
import '../../features/marketplace/screens/seller_dashboard_screen.dart';
import '../../features/marketplace/screens/seller_reports_screen.dart';
import '../../features/marketplace/screens/store_map_screen.dart';
import '../../features/marketplace/screens/product_details_screen.dart';
import '../../features/marketplace/screens/my_orders_screen.dart';
import '../models/store_model.dart';
import '../../features/crops/screens/plant_health_screen.dart';
import '../../features/crops/screens/crop_detail_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_info_screen.dart';
import '../../features/marketplace/screens/catalog_manager_screen.dart';

import '../../core/models/crop_model.dart';
import '../../core/models/user_crop_model.dart';
import '../../features/community/screens/saved_posts_screen.dart';
import '../../features/community/screens/my_posts_screen.dart';
import '../../features/marketplace/screens/checkout_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/merchant_verification_screen.dart';
import '../../features/crops/screens/fertilizer_calculator_screen.dart';
import '../../features/community/screens/user_activity_screen.dart';
import '../models/post_model.dart';
import '../../features/iot/screens/iot_status_screen.dart';
import '../../features/ai/screens/chatbot_screen.dart';
import '../../features/home/screens/weather_detail_screen.dart';
import '../../core/providers/auth_provider.dart';

class AppRouter {
  // Global navigator key for contexts without build context availability
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final GlobalKey<NavigatorState> _shellNavigatorMarket =
      GlobalKey<NavigatorState>(debugLabel: 'shellMarket');
  static final GlobalKey<NavigatorState> _shellNavigatorCrops =
      GlobalKey<NavigatorState>(debugLabel: 'shellCrops');
  static final GlobalKey<NavigatorState> _shellNavigatorProfile =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  // Auth provider reference — injected once after app starts.
  static AuthProvider? _authProvider;

  static void setAuthProvider(AuthProvider provider) {
    _authProvider = provider;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    // Redirect guard: skip SplashScreen when auth state is already known
    // (e.g. after OS kills & restores the process in the background).
    redirect: (context, state) {
      final auth = _authProvider;
      final isSplash = state.matchedLocation == '/';

      // Still initializing or navigating away from splash — let it go.
      if (auth == null || auth.isLoading || !isSplash) return null;

      // Auth state is resolved — skip the 2.5s splash wait.
      if (auth.isAuthenticated) return '/home';
      return '/language';
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/merchant_verification',
        builder: (context, state) => const MerchantVerificationScreen(),
      ),
      GoRoute(
        path: '/disease_detection',
        builder: (context, state) => const DiseaseDetectionScreen(),
      ),
      GoRoute(
        path: '/add_product',
        builder: (context, state) {
          final product = state.extra as ProductModel?;
          return AddProductScreen(productToEdit: product);
        },
      ),
      GoRoute(
        path: '/store_settings',
        builder: (context, state) => const StoreSettingsScreen(),
      ),
      GoRoute(
        path: '/seller_orders',
        builder: (context, state) => const SellerOrdersScreen(),
      ),
      GoRoute(
        path: '/catalog_manager',
        builder: (context, state) => const CatalogManagerScreen(),
      ),
      GoRoute(
        path: '/forum',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForumScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/create_post',
        builder: (context, state) {
          final post = state.extra as PostModel?;
          return CreatePostScreen(postToEdit: post);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/seller_dashboard',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/store_map',
        builder: (context, state) => const StoreMapScreen(),
      ),
      GoRoute(
        path: '/seller_reports',
        builder: (context, state) => const SellerReportsScreen(),
      ),
      GoRoute(
        path: '/store_details',
        builder: (context, state) {
          final store = state.extra as StoreModel;
          return StoreDetailsScreen(store: store);
        },
      ),
      GoRoute(
        path: '/product_details',
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: '/plant_health',
        builder: (context, state) {
          final userCrop = state.extra as UserCropData;
          return PlantHealthScreen(userCrop: userCrop);
        },
      ),
      GoRoute(
        path: '/crop_detail',
        builder: (context, state) {
          final crop = state.extra as Crop;
          return CropDetailScreen(crop: crop);
        },
      ),
      GoRoute(
        path: '/saved_posts',
        builder: (context, state) => const SavedPostsScreen(),
      ),
      GoRoute(
        path: '/my_posts',
        builder: (context, state) => const MyPostsScreen(),
      ),
      GoRoute(
        path: '/user_activity',
        builder: (context, state) => const UserActivityScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/my_orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/edit_profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/info',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return SettingsInfoScreen(
            title: extra['title'] ?? '',
            content: extra['content'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/fertilizer_calculator',
        builder: (context, state) => const FertilizerCalculatorScreen(),
      ),
      GoRoute(
        path: '/iot',
        builder: (context, state) => const IotStatusScreen(),
      ),
      GoRoute(
        path: '/weather',
        builder: (context, state) => const WeatherDetailScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMarket,
            routes: [
              GoRoute(
                path: '/marketplace',
                builder: (context, state) => const MarketplaceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCrops,
            routes: [
              GoRoute(
                path: '/crops',
                builder: (context, state) => const CropsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
