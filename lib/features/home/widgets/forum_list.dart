import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm2/features/community/widgets/social_media_post.dart';

import '../../../core/constants.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/fade_in_slide.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_provider.dart';

class ForumList extends StatelessWidget {
  const ForumList({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.select<HomeProvider, List<PostModel>>((p) => p.posts);
    final isLoading = context.select<HomeProvider, bool>((p) => p.isLoading);

    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: RepaintBoundary(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverMainAxisGroup(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.wp(5), 0, context.wp(5), context.hp(1.5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المنتدى الزراعي',
                  style: TextStyle(
                    fontSize: context.sp(20).clamp(18, 26),
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDark),
                    fontFamily: 'Cairo',
                  ),
                ),
                InkWell(
                  onTap: () => context.push('/forum'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.wp(3).clamp(8.0, 16.0),
                      vertical: context.hp(0.8).clamp(4.0, 10.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'عرض الكل',
                      style: TextStyle(
                        fontSize: context.sp(14).clamp(12, 18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Forum Posts List (Lazy loading via SliverList)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: context.hp(1)),
                child: FadeInSlide(
                  duration: const Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 100 * index),
                  child: SocialMediaPost(
                    post: posts[index],
                  ),
                ),
              );
            },
            childCount: posts.length,
          ),
        ),
      ],
    );
  }
}

