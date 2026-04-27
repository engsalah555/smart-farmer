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

<<<<<<< HEAD
    // Use RepaintBoundary to isolate this widget's painting from the rest of the list
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
                _buildHeader(context, isDark),

                // Post Text
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.wp(5),
                    context.hp(0.5),
                    context.wp(5),
                    context.hp(1.5),
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

                if (post.postImage != null && post.postImage!.isNotEmpty) ...[
                  _buildPostImage(context),
                ],

                // Action Buttons
                _buildActions(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
=======
    return Selector<PostProvider, PostModel?>(
      selector: (context, provider) => provider.getPost(postId),
      builder: (context, post, child) {
        if (post == null) {
          return const SizedBox.shrink();
        }
>>>>>>> 0a37f17d97305944923b55e75747c356e060a2f0

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
<<<<<<< HEAD
=======
                          letterSpacing: 0.1,
>>>>>>> 0a37f17d97305944923b55e75747c356e060a2f0
                        ),
                      ),
                    ),
<<<<<<< HEAD
                    if (post.isAuthorVerified) ...[
                      SizedBox(width: context.wp(1.5)),
                      Icon(
                        Icons.verified,
                        color: context.primary,
                        size: context.sp(14).clamp(12, 18),
                      ),
                    ],
                  ],
                ),
                Text(
                  post.time,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: context.sp(11).clamp(10, 14),

                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildPostMenu(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
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
                    builder: (context) => CommentsSheet(post: post),
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

  Widget _buildAvatar(BuildContext context, bool isDark) {
    final avatarSize = context.wp(12);
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: (post.image != null && post.image!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: post.image!,
                fit: BoxFit.cover,
                // Optimize memory by limiting decoded image size
                memCacheWidth:
                    (avatarSize * MediaQuery.of(context).devicePixelRatio)
                        .toInt(),
                placeholder: (context, url) => Container(
                  color: context.primary.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: context.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    color: context.primary,
                    size: avatarSize * 0.6,
                  ),
                ),
              )
            : Container(
                color: context.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  color: context.primary,
                  size: avatarSize * 0.6,
                ),
              ),
      ),
    );
  }

  Widget _buildPostMenu(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final currentUserId = currentUser?.id;
    // Check if user is owner or admin (assuming admin userType exists or based on role)
    final isAdmin =
        currentUser?.userType == 'admin' || currentUser?.role == 'admin';
    final isMyPost = currentUserId == post.userId;
    final canDelete = isMyPost || isAdmin;

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(Icons.more_horiz, color: Theme.of(context).hintColor),
      onSelected: (value) async {
        if (value == 'edit') {
          context.push('/create_post', extra: post);
        } else if (value == 'delete') {
          _showDeleteDialog(context, isAdmin: isAdmin);
        } else if (value == 'report') {
          _showReportDialog(context);
        }
      },
      itemBuilder: (context) => [
        if (isMyPost)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 20),
                SizedBox(width: 8),
                Text('تعديل', style: TextStyle()),
              ],
            ),
          ),
        if (canDelete)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  isAdmin && !isMyPost ? 'حذف (إشراف)' : 'حذف',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        if (!isMyPost)
          const PopupMenuItem(
            value: 'report',
            child: Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text('إبلاغ عن محتوى', style: TextStyle()),
              ],
            ),
          ),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    String selectedReason = 'inappropriate';
    final TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.wp(5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.report_gmailerrorred_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'إبلاغ عن محتوى',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لماذا تريد الإبلاغ عن هذا المنشور؟',
                    style: TextStyle(),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<String>(
                    groupValue: selectedReason,
                    onChanged: (val) => setState(() => selectedReason = val!),
                    child: Column(
                      children:
                          {
                                'inappropriate': 'محتوى غير لائق',
                                'irrelevant': 'غير متعلق بالزراعة',
                                'spam': 'محتوى غير مرغوب فيه',
                                'harassment': 'تحرش أو إساءة',
                                'other': 'سبب آخر',
                              }.entries
                              .map(
                                (e) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: selectedReason == e.key
                                        ? context.primary.withValues(
                                            alpha: 0.05,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selectedReason == e.key
                                          ? context.primary.withValues(
                                              alpha: 0.2,
                                            )
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: RadioListTile<String>(
                                    title: Text(
                                      e.value,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    value: e.key,
                                    activeColor: context.primary,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'تفاصيل إضافية (اختياري)',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: context.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'تراجع',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await context
                                .read<PostProvider>()
                                .reportPost(
                                  post.id,
                                  selectedReason,
                                  details: detailsController.text,
                                );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم إرسال البلاغ بنجاح، شكراً لك',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'إرسال',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostImage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(4),
        vertical: context.hp(1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Hero(
          tag: 'post_image_${post.id}',
          child: CachedNetworkImage(
            imageUrl: post.postImage!,
            // Optimize memory by limiting decoded image size to screen width
            memCacheWidth:
                (MediaQuery.of(context).size.width *
                        MediaQuery.of(context).devicePixelRatio)
                    .toInt(),
            placeholder: (context, url) => _buildShimmer(context),
            errorWidget: (context, url, error) => _buildImageError(context),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildImageError(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 32),
          const SizedBox(height: 8),
          Text(
            'فشل تحميل الصورة',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, {bool isAdmin = false}) {
    final isMyPost =
        context.read<AuthProvider>().currentUser?.id == post.userId;
    final title = isAdmin && !isMyPost ? 'حذف إشرافي' : 'حذف المنشور';
    final message = isAdmin && !isMyPost
        ? 'هل أنت متأكد من حذف هذا المنشور لمخالفته القوانين؟'
        : 'هل أنت متأكد من رغبتك بحذف هذا المنشور؟';

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: EdgeInsets.all(context.wp(5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin && !isMyPost
                      ? Icons.gavel_rounded
                      : Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('تراجع', style: TextStyle()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await context.read<PostProvider>().deletePost(
                            post.id,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'حذف',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
=======

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
>>>>>>> 0a37f17d97305944923b55e75747c356e060a2f0
    );
  }
}
