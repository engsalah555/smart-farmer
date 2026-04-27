import 'package:flutter_dotenv/flutter_dotenv.dart';

// Umbrella exports for centralized design system
export 'theme/app_colors.dart';
export 'theme/app_typography.dart';
export 'theme/app_decorations.dart';

class AppConstants {
  static const String appName = 'Smart Farm';
  static final String ipAddress = dotenv.env['IP_ADDRESS'] ?? '[IP_ADDRESS]';

  /// يقرأ عنوان الـ API من ملف .env تلقائياً.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://$ipAddress:8000';

  // --- API Endpoints ---
  static const String loginUrl = 'auth/login';
  static const String registerUrl = 'auth/register';
  static const String profileUrl = 'auth/profile';

  static const String cropsUrl = 'crop-guides';
  static const String cropSearchUrl = 'crop-guides/search';
  static const String myCropsUrl = 'farm/my-crops';
  static const String farmCropsUrl = 'farm/crops';

  static const String productsUrl = 'marketplace/products';
  static const String sellerProductsUrl = 'marketplace/seller/products';
  static const String storesUrl = 'marketplace/stores';
  static const String myStoreUrl = 'marketplace/seller/my-store';
  static const String storeUpdateUrl = 'marketplace/seller/my-store/update';
  static const String catalogsUrl = 'marketplace/seller/catalogs';
  static const String checkoutUrl = 'marketplace/checkout';
  static const String ordersUrl = 'marketplace/orders';
  static const String storeOrdersUrl = 'marketplace/seller/orders';

  static const String communityPostsUrl = 'community/posts';
  static const String savedPostsUrl = 'community/saved-posts';
  static const String myPostsUrl = 'community/my-posts';
  static const String userActivityUrl = 'community/activity';

  static const String notificationsUrl = 'notifications';
  static const String homeDataUrl = 'home/data';

  static const String aiAnalyzeUrl = 'ai/analyze-plant';

  /// يبني عنوان URL كامل من مسار نسبي أو يُعيد المسار الكامل كما هو.
  /// الباكند يُعيد URLs كاملة من الـ accessors، لذا لا نُضيف أي بادئة إليها.
  static String? buildUrl(String? path) {
    if (path == null || path.isEmpty) return null;

    // ✅ URL كامل يبدأ بـ http أو https → نُعيده كما هو
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // ✅ مسار Assets المحلية → نُعيده كما هو
    if (path.startsWith('assets/')) return path;

    // تنظيف البادئة الزائدة من الـ slash
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // إزالة التكرارات في السلاش
    while (cleanPath.contains('//')) {
      cleanPath = cleanPath.replaceAll('//', '/');
    }

    // إزالة تكرار storage/storage/ إن وُجد
    if (cleanPath.contains('storage/storage/')) {
      cleanPath = cleanPath.replaceAll('storage/storage/', 'storage/');
    }

    // ✅ مسار نسبي يبدأ بـ storage/ → نُضيف فقط baseUrl
    if (cleanPath.startsWith('storage/')) {
      return '$apiBaseUrl/$cleanPath';
    }

    // ✅ مسار نسبي آخر (مثل avatars/xxx.jpg) → نُضيف storage/
    return '$apiBaseUrl/storage/$cleanPath';
  }
}

