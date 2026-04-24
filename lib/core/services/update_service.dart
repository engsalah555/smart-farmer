import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'locator.dart';

class UpdateService {
  final Dio _dio = locator<Dio>();

  Future<UpdateInfo?> checkUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      debugPrint('Current Version: $currentVersion ($buildNumber)');

      // Fetch version from backend
      // Assuming endpoint /app-version returns version info
      final response = await _dio.get('/app-version');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final latestVersion = data['latest_version'] as String;
        final minVersion = data['min_version'] as String;
        final updateUrl = data['update_url'] as String;
        final updateMessage = data['message'] as String? ?? 'نسخة جديدة متاحة من التطبيق، يرجى التحديث للحصول على أفضل تجربة.';

        final canUpdate = _isVersionGreaterThan(latestVersion, currentVersion);
        final forceUpdate = _isVersionGreaterThan(minVersion, currentVersion);

        if (canUpdate) {
          return UpdateInfo(
            latestVersion: latestVersion,
            currentVersion: currentVersion,
            forceUpdate: forceUpdate,
            updateUrl: updateUrl,
            message: updateMessage,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking update: $e');
    }
    return null;
  }

  bool _isVersionGreaterThan(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1Parts.length; i++) {
      if (i >= v2Parts.length) return true;
      if (v1Parts[i] > v2Parts[i]) return true;
      if (v1Parts[i] < v2Parts[i]) return false;
    }
    return false;
  }
}

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final bool forceUpdate;
  final String updateUrl;
  final String message;

  UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.forceUpdate,
    required this.updateUrl,
    required this.message,
  });
}
