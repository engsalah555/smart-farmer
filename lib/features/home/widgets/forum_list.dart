import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm2/features/community/widgets/social_media_post.dart';
import 'package:smart_farm2/features/community/providers/post_provider.dart';

import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/fade_in_slide.dart';
import 'package:go_router/go_router.dart';
class ForumList extends StatelessWidget {
  const ForumList({super.key});

  @override
  Widget build(BuildContext context) {
    final postIds = context.select<PostProvider, List<String>>((p) => p.postIds.take(2).toList());
    final isLoading = context.select<PostProvider, bool>((p) => p.isLoading);

    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: RepaintBoundary(child: CircularProgressIndicator()),
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
            padding: EdgeInsets.fromLTRB(
              context.wp(5),
              context.hp(1),
              context.wp(5),
              context.hp(2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Optical alignment
              children: [
                Text(
                  'المنتدى الزراعي',
                  style: TextStyle(
                    fontSize: context.sp(20).clamp(18, 26),
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Semantics(
                  label: 'عرض كل منشورات المنتدى',
                  button: true,
                  child: InkWell(
                    onTap: () => context.push('/forum'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.wp(4).clamp(12.0, 20.0),
                        vertical: context.hp(0.6).clamp(4.0, 10.0),
                      ),
                      decoration: BoxDecoration(
                        color: (context.primary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'عرض الكل',
                        style: TextStyle(
                          fontSize: context.sp(13).clamp(11, 16),
                          fontWeight: FontWeight.bold,
                          color: context.primary,
                        ),
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
<<<<<<< HEAD
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: context.hp(1)),
                child: FadeInSlide(
                  duration: const Duration(milliseconds: 500),
                  // Cap delay to first 5 items to prevent performance issues on long lists
                  delay: Duration(milliseconds: index < 5 ? 100 * index : 0),
                  child: SocialMediaPost(
                    postId: postIds[index],
                  ),
                ),
              );
            },
            childCount: postIds.length,
          ),
=======
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: context.hp(1)),
              child: FadeInSlide(
                duration: const Duration(milliseconds: 500),
                // Cap delay to first 5 items to prevent performance issues on long lists
                delay: Duration(milliseconds: index < 5 ? 100 * index : 0),
                child: SocialMediaPost(post: posts[index]),
              ),
            );
          }, childCount: posts.length),
>>>>>>> b0e685f0ffd6a3b1faea4a5064397d709de298ff
        ),
      ],
    );
  }
}
