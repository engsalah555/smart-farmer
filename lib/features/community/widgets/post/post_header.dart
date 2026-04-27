import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/post_model.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/providers/auth_provider.dart';
import 'post_dialogs.dart';

class PostHeader extends StatelessWidget {
  final PostModel post;
  final bool isDark;

  const PostHeader({super.key, required this.post, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.wp(4)),
      child: Row(
        children: [
          _buildAvatar(context),
          SizedBox(width: context.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.author,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: context.sp(15).clamp(13, 19),
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.isAuthorVerified) ...[
                      SizedBox(width: context.wp(1.5)),
                      Icon(
                        Icons.verified,
                        color: AppColors.primary,
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

  Widget _buildAvatar(BuildContext context) {
    final avatarSize = context.wp(12);
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: (post.image != null && post.image!.isNotEmpty)
            ? Image.network(
                post.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildErrorAvatar(avatarSize),
              )
            : _buildErrorAvatar(avatarSize),
      ),
    );
  }

  Widget _buildErrorAvatar(double avatarSize) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        color: AppColors.primary,
        size: avatarSize * 0.6,
      ),
    );
  }

  Widget _buildPostMenu(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final currentUserId = currentUser?.id;
    final isAdmin = currentUser?.userType == 'admin' || currentUser?.role == 'admin';
    final isMyPost = currentUserId == post.userId;
    final canDelete = isMyPost || isAdmin;

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(Icons.more_horiz, color: Theme.of(context).hintColor),
      onSelected: (value) async {
        if (value == 'edit') {
          context.push('/create_post', extra: post);
        } else if (value == 'delete') {
          PostDialogs.showDeleteDialog(context, post, isAdmin: isAdmin);
        } else if (value == 'report') {
          PostDialogs.showReportDialog(context, post);
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
                Icon(Icons.report_problem_outlined, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('إبلاغ عن محتوى', style: TextStyle()),
              ],
            ),
          ),
      ],
    );
  }
}
