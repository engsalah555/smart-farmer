import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_fonts.dart';
import '../providers/post_provider.dart';

class ReportPostDialog extends StatefulWidget {
  final String postId;

  const ReportPostDialog({super.key, required this.postId});

  @override
  State<ReportPostDialog> createState() => _ReportPostDialogState();
}

class _ReportPostDialogState extends State<ReportPostDialog> {
  String selectedReason = 'inappropriate';
  final TextEditingController detailsController = TextEditingController();

  final Map<String, String> reportReasons = {
    'inappropriate': 'محتوى غير لائق',
    'irrelevant': 'غير متعلق بالزراعة',
    'spam': 'محتوى غير مرغوب فيه',
    'harassment': 'تحرش أو إساءة',
    'other': 'سبب آخر',
  };

  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
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
              Text(
                'إبلاغ عن محتوى',
                style: context.title.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'لماذا تريد الإبلاغ عن هذا المنشور؟',
                style: context.body,
              ),
              const SizedBox(height: 16),
              ...reportReasons.entries.map((e) => _buildReasonTile(e.key, e.value)),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                maxLines: 3,
                style: context.subBody,
                decoration: InputDecoration(
                  hintText: 'تفاصيل إضافية (اختياري)',
                  hintStyle: context.subBody.copyWith(
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
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'تراجع',
                        style: context.body.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إرسال',
                        style: context.body.copyWith(
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

  Widget _buildReasonTile(String key, String label) {
    final isSelected = selectedReason == key;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => selectedReason = key),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: context.subBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    final success = await context.read<PostProvider>().reportPost(
          widget.postId,
          selectedReason,
          details: detailsController.text,
        );
    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال البلاغ بنجاح، شكراً لك'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
