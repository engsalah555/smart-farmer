import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/post_model.dart';
import '../../../../core/utils/responsive.dart';
import '../../providers/post_provider.dart';
import '../../providers/comment_provider.dart';
import '../../screens/comments_sheet.dart';

class PostActions extends StatelessWidget {
  final PostModel post;
  final bool isDark;

  const PostActions({super.key, required this.post, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.wp(4),
        context.hp(1),
        context.wp(4),
        context.hp(1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _ActionButton(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  await context.read<PostProvider>().toggleLike(post.id);
                },
                icon: post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                count: post.likesCount.toString(),
                color: post.isLiked
                    ? Colors.redAccent
                    : (isDark ? Colors.white70 : Colors.black54),
                isAnimated: true,
              ),
              SizedBox(width: context.wp(4)),
              _ActionButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (innerContext) => ChangeNotifierProvider.value(
                      value: context.read<CommentProvider>(),
                      child: CommentsSheet(post: post),
                    ),
                  );
                },
                icon: Icons.chat_bubble_outline_rounded,
                count: post.commentsCount.toString(),
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
          _ActionButton(
            onTap: () async {
              HapticFeedback.mediumImpact();
              await context.read<PostProvider>().toggleSave(post.id);
            },
            icon: post.isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            count: '',
            color: post.isSaved
                ? Colors.orange
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String count;
  final Color color;
  final VoidCallback onTap;
  final bool isAnimated;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAnimated)
              RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  tween: Tween(begin: 1.0, end: count != '0' ? 1.2 : 1.0),
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: Icon(icon, size: 20, color: color),
                  ),
                ),
              )
            else
              Icon(icon, size: 20, color: color),
            if (count.isNotEmpty && count != '0') ...[
              const SizedBox(width: 6),
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
