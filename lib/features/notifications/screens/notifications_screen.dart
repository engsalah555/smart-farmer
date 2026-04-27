import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'تحذير', 'معلومة', 'طلبات'];

  List<NotificationModel> _getFiltered(List<NotificationModel> all) {
    switch (_selectedFilter) {
      case 'تحذير':
        return all
            .where((n) => n.type == 'danger' || n.type == 'warning')
            .toList();
      case 'معلومة':
        return all.where((n) => n.type == 'info').toList();
      case 'طلبات':
        return all.where((n) => n.type == 'order').toList();
      default:
        return all;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'danger':
        return Icons.warning_amber_rounded;
      case 'warning':
        return Icons.cloud_outlined;
      case 'info':
        return Icons.tips_and_updates_outlined;
      case 'order':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'danger':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      case 'order':
        return Colors.purple;
      default:
        return context.primary;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF181E14)
            : const Color(0xFFF7F8F6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
          ),
          title: Text(
            'الإشعارات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          centerTitle: true,
          actions: [
            Consumer<NotificationsProvider>(
              builder: (context, provider, _) {
                if (provider.unreadCount == 0) return const SizedBox();
                return TextButton.icon(
                  onPressed: provider.markAllAsRead,
                  icon: const Icon(
                    Icons.done_all,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: const Text(
                    'قراءة الكل',
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<NotificationsProvider>(
          builder: (context, provider, _) {
            final filtered = _getFiltered(provider.notifications);
            final unread = provider.unreadCount;

            return Column(
              children: [
                // Summary Card
                if (unread > 0)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'لديك $unread إشعار${unread > 1 ? 'ات' : ''} غير مقروء${unread > 1 ? 'ة' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Filter Chips
                SizedBox(
                  height: 56,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: _filters.length,
                    itemBuilder: (context, i) {
                      final f = _filters[i];
                      final selected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? context.primary
                                  : (isDark
                                        ? const Color(0xFF27272A)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? context.primary
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: context.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.grey[700]),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // List
                Expanded(
                  child: provider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: context.primary,
                          ),
                        )
                      : filtered.isEmpty
                      ? _buildEmpty(isDark)
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, r) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final n = filtered[index];
                            return _buildNotificationCard(context, n, isDark);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel n,
    bool isDark,
  ) {
    final color = _getColor(n.type);
    return GestureDetector(
      onTap: () {
        context.read<NotificationsProvider>().markAsRead(n.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead
              ? (isDark ? const Color(0xFF27272A) : Colors.white)
              : (isDark
                    ? context.primary.withValues(alpha: 0.08)
                    : context.primary.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isRead
                ? (isDark ? const Color(0xFF3F3F46) : Colors.grey.shade100)
                : color.withValues(alpha: 0.3),
            width: n.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(n.type), color: color, size: 22),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 4, top: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(n.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 56,
              color: context.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا جميع التنبيهات والإشعارات',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
