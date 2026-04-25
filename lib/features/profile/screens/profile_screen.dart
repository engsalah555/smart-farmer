import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../../marketplace/providers/marketplace_provider.dart';
import '../../marketplace/providers/seller_provider.dart';
import '../../marketplace/providers/cart_provider.dart';

/// شاشة الملف الشخصي والإعدادات (Profile/Settings)
/// تتيح للمستخدم تعديل إعدادات الحساب، الإشعارات، الوضع الداكن، والاحتياجات الأمنية
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppProvider, ThemeMode>(
      (p) => p.themeMode,
    );
    final isDark = themeMode == ThemeMode.dark;
    final appProvider = context.read<AppProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: Center(
            child: ProMaxIconButton(
              icon: Icons.arrow_back,
              onTap: () => context.go('/home'),
              color: Colors.white,
              isGlass: false, // Solid primary circle look
            ),
          ),
          title: Text(
            'الإعدادات',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // User Info Header
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final user = auth.currentUser;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: user?.profileImage != null && user!.profileImage!.isNotEmpty
                            ? CachedNetworkImageProvider(user.profileImage!)
                            : null,
                        child: (user?.profileImage == null || user!.profileImage!.isEmpty)
                            ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user?.name ?? 'مستخدم',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              
                            ),
                          ),
                          if (user?.isVerified ?? false) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        user?.phone ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                          
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // First Group: Account, Notifications, Dark Mode, Language
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade100,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      icon: Icons.person_outline,
                      title: 'الحساب',
                      hasArrow: true,
                      onTap: () {
                        context.push('/edit_profile');
                      },
                    ), // Account
                    const Divider(height: 1),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final user = authProvider.currentUser;
                        if (user != null && user.isSeller) {
                          return Column(
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.storefront_outlined,
                                title: 'إدارة متجري',
                                hasArrow: true,
                                onTap: () {
                                  context.push('/seller_dashboard');
                                },
                              ),
                              const Divider(height: 1),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    _buildSettingsTile(
                      context,
                      icon: Icons.notifications_none,
                      title: 'الاشعارات',
                      hasArrow: true,
                      onTap: () {
                        context.push('/notifications');
                      },
                    ), // Notifications
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.shopping_bag_outlined,
                      title: 'طلباتي',
                      hasArrow: true,
                      onTap: () {
                        context.push('/my_orders');
                      },
                    ), // My Orders
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.bookmark_outline,
                      title: 'المنشورات المحفوظة',
                      hasArrow: true,
                      onTap: () {
                        context.push('/saved_posts');
                      },
                    ), // Saved Posts
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.article_outlined,
                      title: 'منشوراتي',
                      hasArrow: true,
                      onTap: () {
                        context.push('/my_posts');
                      },
                    ), // My Posts
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.history_rounded,
                      title: 'نشاطاتي',
                      hasArrow: true,
                      onTap: () {
                        context.push('/user_activity');
                      },
                    ), // User Activity
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.nightlight_round,
                      title: 'الوضع الداكن',
                      isSwitch: true,
                      switchValue: isDark,
                      onToggle: (v) {
                        appProvider.toggleTheme(v);
                      },
                    ), // Dark Mode
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.language,
                      title: 'اللغة',
                      hasArrow: true,
                    ), // Language
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Second Group: Security, Terms, Privacy, Help
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.3
                            : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : Colors.grey.shade100,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      icon: Icons.bar_chart,
                      title: 'التقارير',
                      hasArrow: true,
                      onTap: () {
                        context.push('/reports');
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.security,
                      title: 'الامان',
                      hasArrow: true,
                    ), // Security
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.description_outlined,
                      title: 'الشروط والأحكام',
                      hasArrow: true,
                      onTap: () {
                        context.push('/info', extra: {
                          'title': 'الشروط والأحكام',
                          'content': 'باستخدامك لتطبيق المزرعة الذكية، فإنك توافق على الالتزام بشروط الاستخدام الخاصة بنا. نحن نسعى لتوفير بيئة آمنة للمزارعين لتبادل الخبرات وبيع المنتجات بجودة عالية.',
                        });
                      },
                    ), // Terms
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.lock_outline,
                      title: 'سياسة الخصوصية',
                      hasArrow: true,
                      onTap: () {
                        context.push('/info', extra: {
                          'title': 'سياسة الخصوصية',
                          'content': 'خصوصيتك تهمنا. نحن نقوم بحماية بياناتك الشخصية وبيانات مزرعتك. لا يتم مشاركة أي معلومات مع أطراف ثالثة دون إذنك الصريح.',
                        });
                      },
                    ), // Privacy
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.info_outline,
                      title: 'مساعدة',
                      hasArrow: true,
                      onTap: () {
                        context.push('/info', extra: {
                          'title': 'مساعدة',
                          'content': 'هل لديك استفسار؟ فريق الدعم الفني لدينا متاح دائماً لمساعدتك في حل المشكلات التقنية أو توضيح مميزات التطبيق.',
                        });
                      },
                    ), // Help
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Third Group: Invite, Logout
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade100,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      icon: Icons.group_add_outlined,
                      title: 'ادعُ صديقًا',
                      hasArrow: true,
                    ), // Invite Friend
                    const Divider(height: 1),
                    _buildSettingsTile(
                      context,
                      icon: Icons.logout,
                      title: 'تسجيل الخروج',
                      hasArrow: true,
                      isDestructive: true,
                      onTap: () {
                        _showLogoutConfirmation(context);
                      },
                    ), // Logout
                  ],
                ),
              ),
              const SizedBox(
                height: 120,
              ), // Increased to solve scrolling cut-off
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 10),
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  
                  // مسح حالة جميع الـ Providers المرتبطة بالجلسة قبل تسجيل الخروج
                  context.read<MarketplaceProvider>().clearState();
                  context.read<SellerProvider>().clearState();
                  context.read<CartProvider>().clear();
                  
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.logout();
                  
                  if (context.mounted) {
                    context.go('/auth');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('تأكيد الخروج'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool hasArrow = false,
    bool isSwitch = false,
    bool switchValue = false,
    bool isDestructive = false,
    VoidCallback? onTap,
    Function(bool)? onToggle,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      // Leading: The main icon (on the Right in RTL)
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red.shade400 : AppColors.primary,
        size: 24,
      ),
      // Title: The text (Aligned Right next to Leading in RTL)
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDestructive
              ? Colors.red.shade400
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      // Trailing: The control (Switch or Arrow) (on the Left in RTL)
      trailing: isSwitch
          ? Transform.scale(
              scale: 0.8,
              child: Switch(
                value: switchValue,
                onChanged: onToggle,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primary,
              ),
            )
          : (hasArrow
                ? Icon(
                    Icons
                        .arrow_back_ios_new, // Chevron pointing Left (End) in RTL?
                    // Usually arrow_forward_ios points -> (Right).
                    // arrow_back_ios_new points <- (Left).
                    // In RTL, we go Deeper (Left is "Forward" visually? No).
                    // Start (Right) --> End (Left).
                    // So an arrow pointing Left '<' indicates entering.
                    // Standard iOS RTL chevron points Left.
                    size: 16,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                  )
                : null),
    );
  }
}
