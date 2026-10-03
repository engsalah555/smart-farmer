import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../notifications/providers/notifications_provider.dart';

/// شريط علوي زجاجي ثابت (Sticky Translucent Glass App Bar)
/// يتميز بتصميم فائق الدقة (Aerospace Glassmorphism)
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final double barHeight = statusBarHeight + 68.0;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _HomeTopBarDelegate(
        height: barHeight,
        statusBarHeight: statusBarHeight,
      ),
    );
  }
}

class _HomeTopBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final double statusBarHeight;

  _HomeTopBarDelegate({
    required this.height,
    required this.statusBarHeight,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  bool shouldRebuild(covariant _HomeTopBarDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.statusBarHeight != statusBarHeight;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Consumer2<AuthProvider, NotificationsProvider>(
      builder: (context, authProvider, notificationsProvider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final user = authProvider.currentUser;
        final unreadCount = notificationsProvider.unreadCount;

    final hour = DateTime.now().hour;
    final greeting = (hour >= 4 && hour < 12)
        ? 'صباح الخير'
        : (hour >= 12 && hour < 17)
            ? 'طاب يومك'
            : 'مساء الخير';

    final userName = (user?.name.split(' ').first) ?? 'مزارعنا';

    String userRole = 'المزرعة الذكية';
    if (user != null) {
      if (user.customTitle != null && user.customTitle!.isNotEmpty) {
        userRole = user.customTitle!;
      } else if (user.isSeller) {
        userRole = 'شريك بائع';
      } else if (user.isVerified) {
        userRole = 'مزارع موثق';
      }
    }

    final avatarUrl = user?.profileImage != null
        ? AppConstants.buildUrl(user!.profileImage)
        : null;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
        child: Container(
          height: height,
          padding: EdgeInsets.only(
            top: statusBarHeight + 6,
            bottom: 8,
            left: context.wp(4.5).clamp(16.0, 24.0),
            right: context.wp(4.5).clamp(16.0, 24.0),
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.90),
            border: Border(
              bottom: BorderSide(
                color: context.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── زر الملف الشخصي والأفاتار ────────────────────────────────
              Semantics(
                label: 'الملف الشخصي لـ $userName',
                button: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/profile');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.primary,
                                  width: 2.0,
                                ),
                              ),
                              child: ClipOval(
                                child: avatarUrl != null
                                    ? Image.network(
                                        avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            _buildAvatarFallback(userName),
                                      )
                                    : _buildAvatarFallback(userName),
                              ),
                            ),
                            if (user?.isVerified ?? false)
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkBackground
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    color: AppColors.accent,
                                    size: 15,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: context.wp(3)),
                        // ─── التحية والاسم والدور ─────────────────────────────
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  greeting,
                                  style: TextStyle(
                                    fontSize: context.sp(11).clamp(10, 12),
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.eco_rounded,
                                  size: 12,
                                  color: context.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: context.sp(15).clamp(14, 18),
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.primary.withValues(
                                      alpha: isDark ? 0.16 : 0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.primary.withValues(
                                        alpha: isDark ? 0.35 : 0.22,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        userRole,
                                        style: TextStyle(
                                          fontSize: context.sp(10).clamp(9, 11),
                                          fontWeight: FontWeight.bold,
                                          color: context.primary,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ─── الإجراءات السريعة (تنبيهات + ذكاء اصطناعي) ─────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر المساعد الذكي
                  Semantics(
                    label: 'المساعد الزراعي الذكي',
                    button: true,
                    child: _buildGlassAction(
                      context,
                      icon: Icons.auto_awesome_rounded,
                      iconColor: context.primary,
                      tooltip: 'المساعد الذكي',
                      isAi: true,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/chatbot');
                      },
                    ),
                  ),
                  SizedBox(width: context.wp(2)),

                  // زر التنبيهات مع بادج
                  Semantics(
                    label: 'التنبيهات: $unreadCount إشعار غير مقروء',
                    button: true,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildGlassAction(
                          context,
                          icon: Icons.notifications_none_rounded,
                          iconColor: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          tooltip: 'التنبيهات',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/notifications');
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBackground
                                      : Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name.characters.first : 'م';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGlassAction(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String tooltip,
    required VoidCallback onTap,
    bool isAi = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: isAi
                  ? LinearGradient(
                      colors: [
                        context.primary.withValues(alpha: isDark ? 0.28 : 0.20),
                        context.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isAi
                  ? null
                  : (isDark
                      ? AppColors.darkSurface.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.7)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isAi
                    ? context.primary.withValues(alpha: isDark ? 0.45 : 0.32)
                    : (isDark
                        ? AppColors.darkBorder
                        : AppColors.textMuted.withValues(alpha: 0.15)),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
