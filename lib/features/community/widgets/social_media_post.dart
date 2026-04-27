import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/molecules/pro_max_card.dart';
import '../providers/post_provider.dart';
import 'post/post_header.dart';
import 'post/post_image.dart';
import 'post/post_actions.dart';

class SocialMediaPost extends StatelessWidget {
  final String postId;

  const SocialMediaPost({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Selector<PostProvider, PostModel?>(
      selector: (context, provider) => provider.getPost(postId),
      builder: (context, post, child) {
        if (post == null) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(4),
                vertical: context.hp(0.8),
              ),
              child: ProMaxCard(
                borderRadius: 24,
                elevation: isDark ? 0 : 2,
                backgroundColor: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.8)
                    : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Header
                    PostHeader(post: post, isDark: isDark),

                    // Post Text
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.wp(5),
                        context.hp(1.2),
                        context.wp(5),
                        context.hp(1.8),
                      ),
                      child: Text(
                        post.content,
                        style: TextStyle(
                          fontSize: context.sp(14).clamp(12, 18),
                          height: 1.6,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),

                    if (post.postImage != null && post.postImage!.isNotEmpty)
                      PostImage(post: post),

                    // Action Buttons
                    PostActions(post: post, isDark: isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
