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

    debugPrint('GlobalErrorInterceptor: Error [${err.response?.statusCode}] at [${err.requestOptions.uri}]: $errorMessage');

    if (err.response?.statusCode == 401) {
      debugPrint('401 Unauthorized detected. Clearing session and redirecting to /auth...');

      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('auth_token');
        prefs.remove('user_data');
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.router.go('/auth');
      });
    }

    super.onError(err, handler);
  }
}
