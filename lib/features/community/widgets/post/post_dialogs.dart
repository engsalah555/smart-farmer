import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/post_model.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../providers/post_provider.dart';

class PostDialogs {
  static void showReportDialog(BuildContext context, PostModel post) {
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                      children: {
                        'inappropriate': 'محتوى غير لائق',
                        'irrelevant': 'غير متعلق بالزراعة',
                        'spam': 'محتوى غير مرغوب فيه',
                        'harassment': 'تحرش أو إساءة',
                        'other': 'سبب آخر',
                      }.entries.map(
                        (e) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: selectedReason == e.key
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedReason == e.key
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : Colors.transparent,
                            ),
                          ),
                          child: RadioListTile<String>(
                            title: Text(
                              e.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: e.key,
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ).toList(),
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
                        borderSide: const BorderSide(
                          color: AppColors.primary,
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
                            final success = await context.read<PostProvider>().reportPost(
                              post.id,
                              selectedReason,
                              details: detailsController.text,
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم إرسال البلاغ بنجاح، شكراً لك'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'إرسال',
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
        ),
      ),
    );
  }

  static void showDeleteDialog(BuildContext context, PostModel post, {bool isAdmin = false}) {
    final isMyPost = context.read<AuthProvider>().currentUser?.id == post.userId;
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
                  isAdmin && !isMyPost ? Icons.gavel_rounded : Icons.delete_outline_rounded,
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
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('تراجع'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await context.read<PostProvider>().deletePost(post.id);
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

class RadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
