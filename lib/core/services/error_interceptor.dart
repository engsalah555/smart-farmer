import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_router.dart';

class GlobalErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'حدث خطأ غير متوقع.';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'انتهى وقت الاتصال المستغرق. يرجى التحقق من الإنترنت.';
        break;
      case DioExceptionType.badResponse:
        errorMessage =
            'تلقينا استجابة غير صالحة من الخادم. (الرمز: ${err.response?.statusCode})';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'تم إلغاء الطلب.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'فشل الاتصال بالخادم. تأكد من أنك متصل بالإنترنت.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'فشل الاتصال: ${err.message}';
        break;
      default:
        errorMessage = 'حدث خطأ غير متوقع بالنظام.';
    }

    debugPrint('GlobalErrorInterceptor: $errorMessage');

    if (err.response?.statusCode == 401) {
      debugPrint('401 Unauthorized detected. Forcing logout...');

      // Clear auth data asynchronously
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('auth_token');
        prefs.remove('user_data');
      });

      // Use the root navigator key to redirect to login
      // Since we are using GoRouter, we can use go() or pushReplacement()
      // AppRouter.router.go('/auth') is the preferred way with GoRouter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.router.go('/auth');
      });
    }

    // You could also use a global scaffold messenger key to show a SnackBar here
    // e.g., globalNavigatorKey.currentContext...

    super.onError(err, handler);
  }
}
