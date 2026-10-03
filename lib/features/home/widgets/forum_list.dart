import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final postIds = context.select<PostProvider, List<String>>(
      (p) => p.postIds.take(2).toList(),
    );
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
              context.wp(4.5).clamp(16.0, 24.0),
              context.hp(1),
              context.wp(4.5).clamp(16.0, 24.0),
              context.hp(1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المنتدى الزراعي',
                      style: TextStyle(
                        fontSize: context.sp(18).clamp(16, 22),
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'تجارب ومناقشات مجتمع المزارعين',
                      style: TextStyle(
                        fontSize: context.sp(11).clamp(10, 13),
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Semantics(
                  label: 'عرض كل منشورات المنتدى',
                  button: true,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/forum');
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.wp(3.5).clamp(10.0, 16.0),
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (context.primary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.primary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'عرض الكل',
                            style: TextStyle(
                              fontSize: context.sp(12).clamp(11, 14),
                              fontWeight: FontWeight.bold,
                              color: context.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: context.primary,
                          ),
                        ],
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
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: context.hp(1)),
              child: FadeInSlide(
                duration: const Duration(milliseconds: 500),
                // Cap delay to first 5 items to prevent performance issues on long lists
                delay: Duration(milliseconds: index < 5 ? 100 * index : 0),
                child: SocialMediaPost(postId: postIds[index]),
              ),
            );
          }, childCount: postIds.length),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}
