import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';

class AlertsService {
  final Dio _dio = Dio();
  final String _baseUrl = '${AppConstants.apiBaseUrl}/api';

  Future<List<dynamic>> getActiveAlerts() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/warnings',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as List<dynamic>;
      } else {
        debugPrint('Failed to load alerts: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      debugPrint('Alerts Service Dio Error: $e');
      return [];
    } catch (e) {
      debugPrint('Alerts Service Error: $e');
      return [];
    }
  }
}
