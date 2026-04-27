
import 'package:dio/dio.dart';
import 'app_exception.dart';

class ErrorHandler {
  static AppException handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is AppException) {
      return error;
    } else {
      return AppException(
        message: 'حدث خطأ غير متوقع.',
        technicalMessage: error.toString(),
      );
    }
  }

  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(technicalMessage: error.message);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          return AuthenticationException();
        }

        if (statusCode == 422) {
          String? message;
          Map<String, dynamic>? errors;

          if (data is Map<String, dynamic>) {
            message = data['message'];
            if (data['errors'] is Map<String, dynamic>) {
              errors = data['errors'];
              // If we have validation errors, pick the first one for the main message
              if (errors!.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  message = firstError.first.toString();
                }
              }
            }
          }
          return ValidationException(message: message, errors: errors);
        }

        return ServerException(
          statusCode: statusCode,
          technicalMessage: error.message,
          message: data is Map ? data['message'] : null,
        );

      case DioExceptionType.connectionError:
        return NetworkException(technicalMessage: error.message);

      default:
        return AppException(
          message: 'حدث خطأ في الاتصال.',
          technicalMessage: error.message,
        );
    }
  }
}
