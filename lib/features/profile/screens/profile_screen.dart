import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/atoms/pro_max_icon_button.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../marketplace/providers/marketplace_provider.dart';
import '../../marketplace/providers/seller_provider.dart';
import '../../marketplace/providers/cart_provider.dart';
import '../widgets/profile_widgets.dart';

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('الإعدادات', style: AppTypography.h3(isDark: isDark)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProMaxIconButton(
              icon: Icons.logout_rounded,
              onTap: () => _showLogoutConfirmation(context),
              color: context.primary,
              isGlass: false,
              size: 38,
              iconSize: 18,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // User Info Header
            FadeInSlide(
              duration: const Duration(milliseconds: 400),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final user = auth.currentUser;
                  return ProfileHeader(
                    name: user?.name ?? 'مستخدم',
                    phone: user?.phone,
                    imageUrl: user?.profileImage,
                    isVerified: user?.isVerified ?? false,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // First Group: Account, Shop, Notifications
            FadeInSlide(
              duration: const Duration(milliseconds: 500),
              direction: FadeInSlideDirection.btt,
              child: SettingsGroup(
                title: 'الحساب والمتجر',
                children: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: 'تعديل الملف الشخصي',
                    hasArrow: true,
                    onTap: () => context.push('/edit_profile'),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final user = authProvider.currentUser;
                      if (user != null && user.isSeller) {
                        return SettingsTile(
                          icon: Icons.storefront_outlined,
                          title: 'إدارة متجري',
                          hasArrow: true,
                          onTap: () => context.push('/seller_dashboard'),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SettingsTile(
                    icon: Icons.notifications_none,
                    title: 'الإشعارات',
                    hasArrow: true,
                    onTap: () => context.push('/notifications'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Second Group: Orders, Activities
            FadeInSlide(
              duration: const Duration(milliseconds: 600),
              direction: FadeInSlideDirection.btt,
              child: SettingsGroup(
                title: 'النشاطات والطلبات',
                children: [
                  SettingsTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'طلباتي',
                    hasArrow: true,
                    onTap: () => context.push('/my_orders'),
                  ),
                  SettingsTile(
                    icon: Icons.bookmark_outline,
                    title: 'المنشورات المحفوظة',
                    hasArrow: true,
                    onTap: () => context.push('/saved_posts'),
                  ),
                  SettingsTile(
                    icon: Icons.article_outlined,
                    title: 'منشوراتي',
                    hasArrow: true,
                    onTap: () => context.push('/my_posts'),
                  ),
                  SettingsTile(
                    icon: Icons.history_rounded,
                    title: 'نشاطاتي',
                    hasArrow: true,
                    onTap: () => context.push('/user_activity'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Third Group: Preferences
            FadeInSlide(
              duration: const Duration(milliseconds: 700),
              direction: FadeInSlideDirection.btt,
              child: SettingsGroup(
                title: 'التفضيلات',
                children: [
                  SettingsTile(
                    icon: Icons.nightlight_round,
                    title: 'الوضع الداكن',
                    isSwitch: true,
                    switchValue: isDark,
                    onToggle: (v) => appProvider.toggleTheme(v),
                  ),
                  SettingsTile(
                    icon: Icons.language,
                    title: 'اللغة',
                    subtitle: appProvider.locale.languageCode == 'ar'
                        ? 'العربية'
                        : 'English',
                    hasArrow: true,
                    onTap: () {
                      // Logic for language selection
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fourth Group: Support & Legal
            FadeInSlide(
              duration: const Duration(milliseconds: 800),
              direction: FadeInSlideDirection.btt,
              child: SettingsGroup(
                title: 'الدعم والمساعدة',
                children: [
                  SettingsTile(
                    icon: Icons.bar_chart,
                    title: 'التقارير التحليلية',
                    hasArrow: true,
                    onTap: () => context.push('/reports'),
                  ),
                  SettingsTile(
                    icon: Icons.security,
                    title: 'الأمان',
                    hasArrow: true,
                    onTap: () {},
                  ),
                  SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'الشروط والأحكام',
                    hasArrow: true,
                    onTap: () {
                      context.push(
                        '/info',
                        extra: {
                          'title': 'الشروط والأحكام',
                          'content':
                              'باستخدامك لتطبيق المزرعة الذكية، فإنك توافق على الالتزام بشروط الاستخدام الخاصة بنا. نحن نسعى لتوفير بيئة آمنة للمزارعين لتبادل الخبرات وبيع المنتجات بجودة عالية.',
                        },
                      );
                    },
                  ),
                  SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'سياسة الخصوصية',
                    hasArrow: true,
                    onTap: () {
                      context.push(
                        '/info',
                        extra: {
                          'title': 'سياسة الخصوصية',
                          'content':
                              'خصوصيتك تهمنا. نحن نقوم بحماية بياناتك الشخصية وبيانات مزرعتك. لا يتم مشاركة أي معلومات مع أطراف ثالثة دون إذنك الصريح.',
                        },
                      );
                    },
                  ),
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'مساعدة',
                    hasArrow: true,
                    onTap: () {
                      context.push(
                        '/info',
                        extra: {
                          'title': 'مساعدة',
                          'content':
                              'هل لديك استفسار؟ فريق الدعم الفني لدينا متاح دائماً لمساعدتك في حل المشكلات التقنية أو توضيح مميزات التطبيق.',
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fifth Group: Account Actions
            FadeInSlide(
              duration: const Duration(milliseconds: 900),
              direction: FadeInSlideDirection.btt,
              child: SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.group_add_outlined,
                    title: 'ادعُ صديقًا',
                    hasArrow: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.border(isDark)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('تسجيل الخروج', style: AppTypography.h3(isDark: isDark)),
            ],
          ),
          content: Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
            style: AppTypography.bodyMedium(isDark: isDark),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'إلغاء',
                style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

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
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'تأكيد الخروج',
                style: AppTypography.buttonLabel(isDark: isDark),
              ),
            ),
          ],
        );
      },
    );
  }
}
