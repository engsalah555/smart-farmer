import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A base service to handle common patterns in API calls.
/// Standardizes response parsing and error handling for the Laravel backend.
abstract class BaseApiService {
  final Dio dio;

  BaseApiService(this.dio);

  /// Basic memory cache for GET requests
  final Map<String, dynamic> _cache = {};

  /// Standard wrapper for GET requests
  Future<T?> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) mapper,
    bool useCache = false,
  }) async {
    final cacheKey = '$path${queryParameters?.toString()}';
    
    if (useCache && _cache.containsKey(cacheKey)) {
      debugPrint('Returning cached data for: $path');
      return mapper(_cache[cacheKey]);
    }

    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      final result = _processResponse(response, mapper);
      
      if (useCache && response.data['success'] == true) {
        if (response.data is Map<String, dynamic> && (response.data as Map<String, dynamic>).containsKey('meta')) {
          _cache[cacheKey] = response.data;
        } else {
          _cache[cacheKey] = response.data['data'];
        }
      }
      
      return result;
    } catch (e) {
      _handleError(e, path);
      rethrow;
    }
  }

  /// Standard wrapper for POST requests
  Future<T?> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) mapper,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _processResponse(response, mapper);
    } catch (e) {
      _handleError(e, path);
      rethrow;
    }
  }

  /// Standard wrapper for PUT requests
  Future<T?> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) mapper,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _processResponse(response, mapper);
    } catch (e) {
      _handleError(e, path);
      rethrow;
    }
  }

  /// Standard wrapper for DELETE requests
  Future<bool> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.delete(path, queryParameters: queryParameters);
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      _handleError(e, path);
      return false;
    }
  }

  /// Processes the Dio response and applies the mapper if successful.
  T? _processResponse<T>(Response response, T Function(dynamic data) mapper) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;
      if (responseData['success'] == true) {
        if (responseData is Map<String, dynamic> && responseData.containsKey('meta')) {
          return mapper(responseData);
        }
        return mapper(responseData['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: responseData['message'] ?? 'Unknown error occurred',
        );
      }
    }
    return null;
  }

  void _handleError(Object e, String path) {
    debugPrint('API Error at [$path]: $e');
  }
}
