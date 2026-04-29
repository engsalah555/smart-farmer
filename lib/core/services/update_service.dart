import 'package:flutter/foundation.dart';

/// خدمة التحديث — معطّلة (النسخة الحالية هي الأحدث)
/// لتفعيل التحديث مستقبلاً: أضف النسخة الجديدة في [_latestVersion]
class UpdateService {
  Future<UpdateInfo?> checkUpdate() async {
    debugPrint('UpdateService: No update available. Current version is the latest.');
    return null; // لا يوجد تحديث
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
