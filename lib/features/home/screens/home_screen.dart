import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../providers/home_provider.dart';
import '../widgets/forum_list.dart';
import '../widgets/home_alerts.dart';
import '../widgets/home_header.dart';


/// شاشة الصفحة الرئيسية للتطبيق
/// تعرض معلومات المستخدم، بيانات المستشعرات، وآخر منشورات المنتدى
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الشاشة (Lazy Loading)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeProvider>();
      if (provider.posts.isEmpty && !provider.isLoading) {
        provider.init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // بناء رأس الصفحة (Header) - يبقى ثابتاً في الأعلى
          const HomeHeader(),

          // الجزء القابل للتمرير المحسن بنظام Slivers
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<HomeProvider>().init();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: context.hp(2)),
                  ),


                  // التنبيهات العاجلة
                  const SliverToBoxAdapter(
                    child: HomeAlerts(),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: context.hp(2)),
                  ),

                  // قائمة المنشورات من المنتدى (Sliver-based)
                  const ForumList(),

                  SliverToBoxAdapter(
                    child: SizedBox(height: context.hp(12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

