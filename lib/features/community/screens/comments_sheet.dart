import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/comment_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/comment_provider.dart';
import '../widgets/skeleton_post.dart';

class CommentsSheet extends StatefulWidget {
  final PostModel post;

  const CommentsSheet({super.key, required this.post});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().fetchComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final comment = await context.read<CommentProvider>().addComment(widget.post.id, text);
      if (comment != null && mounted) {
        final count = context.read<CommentProvider>().getComments(widget.post.id).length;
        context.read<PostProvider>().updateCommentCount(widget.post.id, count);
      }
      if (!mounted) return;
      _commentController.clear();
      FocusScope.of(context).unfocus();
      HapticFeedback.lightImpact();

      // Scroll to bottom to see the new comment
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إضافة التعليق. حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: context.hp(85),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.wp(2),
                context.hp(1),
                context.wp(5),
                context.hp(1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<PostProvider>(
                      builder: (context, provider, _) {
<<<<<<< HEAD
                        final currentPost =
                            [
                              ...provider.posts,
                              ...provider.myPosts,
                              ...provider.savedPosts,
                            ].firstWhere(
                              (p) => p.id == widget.post.id,
                              orElse: () => widget.post,
                            );

=======
                        final currentPost = provider.getPost(widget.post.id) ?? widget.post;
                        
>>>>>>> 0a37f17d97305944923b55e75747c356e060a2f0
                        return Text(
                          'التعليقات (${currentPost.commentsCount})',
                          style: TextStyle(
                            fontSize: context.sp(18).clamp(16, 22),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: context.wp(6)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Comments List
            Expanded(
              child: Consumer<CommentProvider>(
                builder: (context, provider, _) {
                  final comments = provider.getComments(widget.post.id);
                  final isLoading = provider.isCommentsLoading(widget.post.id);

                  if (isLoading && comments.isEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 6,
                      itemBuilder: (context, index) => const SkeletonComment(),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.fetchComments(widget.post.id),
                    child: comments.isEmpty
                        ? _buildEmptyComments()
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: comments.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildCommentItem(
                                context,
                                comments[index],
                              );
                            },
                          ),
                  );
                },
              ),
            ),

            // Input Field
            _buildCommentInput(bottomInset),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyComments() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: context.hp(50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(context.wp(6)),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: context.wp(16),
                  color: context.primary.withValues(alpha: 0.3),
                ),
              ),
              SizedBox(height: context.hp(3)),
              Text(
                'لا توجد تعليقات بعد',
                style: TextStyle(
                  fontSize: context.sp(18).clamp(16, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.hp(1)),
              Text(
                'كن أول من يشارك رأيه في هذا الموضوع!',
                style: TextStyle(
                  fontSize: context.sp(14).clamp(12, 16),
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput(double bottomInset) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + bottomInset + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardTheme.color ??
            (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 4,
              minLines: 1,
              style: TextStyle(fontSize: context.sp(15).clamp(13, 17)),
              decoration: InputDecoration(
                hintText: 'اكتب تعليقاً...',
                hintStyle: TextStyle(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                  fontSize: context.sp(14).clamp(12, 16),
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.wp(5),
                  vertical: context.hp(1),
                ),
              ),
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _submitComment,
            child: Container(
              height: context.wp(12),
              width: context.wp(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.primary,
                    context.primary.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isSubmitting
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, Comment comment) {
    final isOwner =
        context.read<AuthProvider>().currentUser?.id.toString() ==
        comment.userId.toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with CachedNetworkImage
        ClipRRect(
          borderRadius: BorderRadius.circular(context.wp(5)),
          child: Container(
            width: context.wp(10),
            height: context.wp(10),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
            ),
            child: comment.userAvatar != null
                ? CachedNetworkImage(
                    imageUrl: comment.userAvatar!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        width: context.wp(4),
                        height: context.wp(4),
                        child: const CircularProgressIndicator(strokeWidth: 1),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Text(
                        comment.userName.isNotEmpty
                            ? comment.userName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: context.sp(14).clamp(12, 16),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      comment.userName.isNotEmpty
                          ? comment.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: context.sp(14).clamp(12, 16),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(14).clamp(12, 16),
                              ),
                            ),
                            if (comment.isVerified) ...[
                              SizedBox(width: context.wp(1)),
                              Icon(
                                Icons.verified,
                                color: context.primary,
                                size: context.sp(14).clamp(12, 16),
                              ),
                            ],
                          ],
                        ),
                        if (isOwner) _buildCommentOptions(context, comment),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontSize: context.sp(14).clamp(12, 16),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 4),
                child: Row(
                  children: [
                    Text(
                      comment.createdAtFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Like button for comment (Optional, but adds to the Pro Max feel)
                    /*
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'إعجاب',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    */
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentOptions(BuildContext context, Comment comment) {
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_horiz_rounded,
          size: 18,
          color: Theme.of(context).hintColor,
        ),
        onSelected: (value) {
          if (value == 'edit') {
            _showEditDialog(context, comment);
          } else if (value == 'delete') {
            _showDeleteConfirm(context, comment);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 18),
                SizedBox(width: 12),
                Text('تعديل'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                SizedBox(width: 12),
                Text('حذف', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Comment comment) {
    final controller = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تعديل التعليق', textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                context.read<CommentProvider>().editComment(
                  widget.post.id,
                  comment.id,
                  controller.text.trim(),
                );
              }
            },
            child: const Text('حفظ التعديل'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف التعليق', textAlign: TextAlign.right),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف هذا التعليق؟ لا يمكن التراجع عن هذا الإجراء.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
              context.read<CommentProvider>().deleteComment(
                widget.post.id,
                comment.id,
              ).then((success) {
                if (success && context.mounted) {
                  final count = context.read<CommentProvider>().getComments(widget.post.id).length;
                  context.read<PostProvider>().updateCommentCount(widget.post.id, count);
                }
              });
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
