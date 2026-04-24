import 'package:dio/dio.dart';

/// نموذج موحد لاستجابات API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.success({
    required T data,
    String? message,
    int statusCode = 200,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  factory ApiResponse.fromDioError(DioException error) {
    String message = 'حدث خطأ غير متوقع';
    int? statusCode = error.response?.statusCode;
    Map<String, dynamic>? errors;

    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        errors = data['errors'];
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'انتهت مهلة الاتصال';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'تحقق من اتصالك بالإنترنت';
    }

    return ApiResponse.error(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}

/// نموذج Result للتعامل مع النجاح/الفشل
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data) : error = null, isSuccess = true;

  Result.failure(this.error) : data = null, isSuccess = false;

  bool get isFailure => !isSuccess;

  /// تنفيذ دالة عند النجاح
  Result<T> onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) {
      callback(data as T);
    }
    return this;
  }

  /// تنفيذ دالة عند الفشل
  Result<T> onFailure(void Function(String error) callback) {
    if (isFailure && error != null) {
      callback(error!);
    }
    return this;
  }

  /// تحويل Result إلى نوع آخر
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      try {
        return Result.success(transform(data as T));
      } catch (e) {
        return Result.failure(e.toString());
      }
    }
    return Result.failure(error ?? 'Unknown error');
  }
}
