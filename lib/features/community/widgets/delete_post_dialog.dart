import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/responsive.dart';
import '../providers/post_provider.dart';

class DeletePostDialog extends StatelessWidget {
  final String postId;
  final bool isAdmin;
  final bool isMyPost;

  const DeletePostDialog({
    super.key,
    required this.postId,
    this.isAdmin = false,
    this.isMyPost = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = isAdmin && !isMyPost ? 'حذف إشرافي' : 'حذف المنشور';
    final message = isAdmin && !isMyPost
        ? 'هل أنت متأكد من حذف هذا المنشور لمخالفته القوانين؟'
        : 'هل أنت متأكد من رغبتك بحذف هذا المنشور؟';

    return Directionality(
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'تراجع',
                        style: TextStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<PostProvider>().deletePost(postId);
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
