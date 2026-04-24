import 'package:flutter/foundation.dart';
import '../../../core/constants.dart';
import '../../../core/services/base_api_service.dart';

class NotificationService extends BaseApiService {
  NotificationService(super.dio);

  /// Fetch user notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    return await get<List<Map<String, dynamic>>>(
          AppConstants.notificationsUrl,
          mapper: (data) => (data as List).cast<Map<String, dynamic>>(),
        ) ??
        [];
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String id) async {
    final result = await post<bool>(
      '${AppConstants.notificationsUrl}/$id/read',
      mapper: (data) => true,
    );
    return result ?? false;
  }

  /// Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    final result = await post<bool>(
      '${AppConstants.notificationsUrl}/read-all',
      mapper: (data) => true,
    );
    return result ?? false;
  }

  /// Schedule a watering reminder for a specific plant
  Future<void> scheduleWateringReminder({
    required int id,
    required String plantName,
    required DateTime scheduledDate,
  }) async {
    // to schedule the local notification.
    debugPrint('Scheduling watering reminder for $plantName at $scheduledDate');
  }

  /// Cancel a specific reminder
  Future<void> cancelReminder(int id) async {
    // Placeholder to cancel local notification
    debugPrint('Cancelling reminder with id: $id');
  }
}
