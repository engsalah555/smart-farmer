import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/api_response.dart';

/// كلاس أساسي لجميع الخدمات
/// يوفر وظائف مشتركة لمعالجة الأخطاء والاستجابات
abstract class BaseService {
  final Dio dio;

  BaseService(this.dio);

  /// معالجة استجابة API وتحويلها إلى ApiResponse
  ApiResponse<T> handleResponse<T>(
    Response response,
    T Function(dynamic) fromJson,
  ) {
    try {
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = fromJson(response.data);
        return ApiResponse.success(
          data: data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse.error(
          message: 'فشل الطلب',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('Error parsing response: $e');
      return ApiResponse.error(message: 'خطأ في معالجة البيانات');
    }
  }

  /// معالجة أخطاء Dio
  ApiResponse<T> handleError<T>(dynamic error) {
    if (error is DioException) {
      return ApiResponse.fromDioError(error);
    } else {
      return ApiResponse.error(message: error.toString());
    }
  }

  /// تنفيذ طلب API مع معالجة الأخطاء
  Future<ApiResponse<T>> executeRequest<T>(
    Future<Response> Function() request,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await request();
      return handleResponse(response, fromJson);
    } catch (e) {
      return handleError(e);
    }
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return executeRequest(
      () => dio.get(path, queryParameters: queryParameters),
      fromJson,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path,
    T Function(dynamic) fromJson, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return executeRequest(
      () => dio.post(path, data: data, queryParameters: queryParameters),
      fromJson,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path,
    T Function(dynamic) fromJson, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return executeRequest(
      () => dio.put(path, data: data, queryParameters: queryParameters),
      fromJson,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return executeRequest(
      () => dio.delete(path, queryParameters: queryParameters),
      fromJson,
    );
  }
}
