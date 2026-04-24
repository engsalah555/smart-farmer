import 'package:flutter/material.dart';

import '../../../core/services/locator.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/providers/base_provider.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'info', 'warning', 'danger'
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Map backend type to UI type
    String mapType(String backendType) {
      switch (backendType) {
        case 'general':
        case 'like':
        case 'comment':
          return 'info';
        case 'order':
          return 'order';
        case 'danger':
        case 'warning':
        case 'info':
          return backendType; // Fallback for explicitly defined UI types
        default:
          return 'info';
      }
    }

    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'إشعار',
      message: json['body'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      type: mapType(json['type'] ?? ''),
      isRead: json['read_at'] != null,
    );
  }
}

class NotificationsProvider extends BaseProvider {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationsProvider() {
    _loadNotifications();
  }

  Future<void> fetchNotifications() async {
    await execute(() async {
      final List<Map<String, dynamic>> targetData =
          await locator<NotificationService>().getNotifications();
      _notifications = targetData
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    });
  }

  Future<void> _loadNotifications() async {
    await fetchNotifications();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      // Optimistic update
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      try {
        await locator<NotificationService>().markNotificationAsRead(id);
      } catch (e) {
        // Revert on failure
        _notifications[index] = _notifications[index].copyWith(isRead: false);
        notifyListeners();
        debugPrint('Error marking notification as read: $e');
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (_notifications.every((n) => n.isRead)) return;

    final backup = List<NotificationModel>.from(_notifications);

    // Optimistic update
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();

    try {
      await locator<NotificationService>().markAllNotificationsAsRead();
    } catch (e) {
      // Revert on failure
      _notifications = backup;
      notifyListeners();
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
