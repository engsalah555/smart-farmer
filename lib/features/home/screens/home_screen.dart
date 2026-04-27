import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/responsive.dart';
import '../providers/home_provider.dart';
import '../widgets/forum_list.dart';
import '../widgets/home_alerts.dart';
import '../widgets/home_header.dart';
import '../../community/providers/post_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      final postProvider = context.read<PostProvider>();
      
      if (homeProvider.posts.isEmpty && !homeProvider.isLoading) {
        homeProvider.init();
      }
      
      if (postProvider.postIds.isEmpty && !postProvider.isLoading) {
        postProvider.fetchPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            const HomeHeader(),

            Expanded(
              child: Semantics(
                label: 'القائمة الرئيسية قابلة للسحب للتحديث',
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

                      const SliverToBoxAdapter(child: HomeAlerts()),

                      SliverToBoxAdapter(
                        child: SizedBox(height: context.hp(2)),
                      ),

                      const ForumList(),

                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: context.hp(12).clamp(80.0, 120.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
