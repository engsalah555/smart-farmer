import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../community/providers/post_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/forum_list.dart';
import '../widgets/home_alerts.dart';
import '../widgets/home_climate_card.dart';
import '../widgets/home_top_bar.dart';

/// شاشة الصفحة الرئيسية للتطبيق بتصميم عصري فائق الدقة (Aerospace Glassmorphism)
/// تضم حصرياً بيانات الشاشة الرئيسية الأساسية مع ترقيتها:
/// 1. الشريط الزجاجي العلوي (الملف الشخصي، الترحيب، الإشعارات، والمساعد الذكي).
/// 2. بطاقة الطقس والمناخ المتقدمة (الحرارة، الحالة، الرطوبة، الرياح، الأمطار، الساعة، زر التحديث، وزر التقرير).
/// 3. التنبيهات العاجلة للمزرعة.
/// 4. منشورات وتفاعلات المنتدى الزراعي.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      final postProvider = context.read<PostProvider>();
      final notificationsProvider = context.read<NotificationsProvider>();

      if ((homeProvider.posts.isEmpty || homeProvider.weatherData == null) &&
          !homeProvider.isLoading &&
          !homeProvider.isWeatherLoading) {
        homeProvider.init();
      }

      if (postProvider.postIds.isEmpty && !postProvider.isLoading) {
        postProvider.fetchPosts();
      }

      // تحديث عداد الإشعارات
      notificationsProvider.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(),
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async {
            await Future.wait([
              context.read<HomeProvider>().init(),
              context.read<PostProvider>().fetchPosts(),
              context.read<AuthProvider>().refreshProfile(),
              context.read<NotificationsProvider>().fetchNotifications(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ─── 1. الشريط العلوي الزجاجي الثابت (Sticky Glass Top Bar) ────
              const HomeTopBar(),

              SliverToBoxAdapter(child: SizedBox(height: context.hp(1.6))),

              // ─── 2. بطاقة الطقس والمناخ الذكية (Climate Hero Card) ────────
              const SliverToBoxAdapter(
                child: FadeInSlide(
                  direction: FadeInSlideDirection.btt,
                  duration: Duration(milliseconds: 500),
                  child: HomeClimateCard(),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: context.hp(1.6))),

              // ─── 3. التنبيهات العاجلة (Urgent Alerts Carousel) ──────────────
              const SliverToBoxAdapter(child: HomeAlerts()),

              SliverToBoxAdapter(child: SizedBox(height: context.hp(1.6))),

              // ─── 4. المنتدى الزراعي (Community Discussions Feed) ───────────
              const ForumList(),

              // مساحة سفلية لاستيعاب شريط التنقل السفلي والزر العائم (FAB)
              SliverToBoxAdapter(
                child: SizedBox(height: context.hp(14).clamp(95.0, 135.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
