import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/dashed_border.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _selectedImage;
  String _documentType = 'هوية وطنية'; // Default type
  final List<String> _documentTypes = [
    'هوية وطنية',
    'رخصة قيادة',
    'جواز سفر',
    'سجل تجاري',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في اختيار الصورة: $e')),
        );
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر مصدر الصورة',
              style: AppTypography.h3(isDark: Theme.of(context).brightness == Brightness.dark),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.bodyMedium(isDark: isDark)),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة الوثيقة أولاً')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.submitVerification(
      documentType: _documentType,
      imagePath: _selectedImage!.path,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب التوثيق بنجاح')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'فشل في إرسال الطلب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final status = auth.verificationRequest;

    return Scaffold(
      appBar: AppBar(
        title: Text('توثيق الحساب', style: AppTypography.h3(isDark: isDark)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Info
            if (status != null) _buildStatusCard(status, isDark),
            
            const SizedBox(height: 24),
            
            Text(
              'للحصول على شارة التوثيق والتمتع بكافة مميزات التطبيق، يرجى رفع صورة واضحة لإحدى الوثائق الرسمية التالية:',
              style: AppTypography.bodyMedium(isDark: isDark),
            ),
            
            const SizedBox(height: 24),
            
            // Document Type Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _documentType,
                  isExpanded: true,
                  items: _documentTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type, style: AppTypography.bodyLarge(isDark: isDark)),
                  )).toList(),
                  onChanged: auth.isVerificationPending ? null : (v) => setState(() => _documentType = v!),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Image Upload Area
            GestureDetector(
              onTap: auth.isVerificationPending ? null : _showImageSourceActionSheet,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: context.cardBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: context.border,
                    strokeWidth: 2,
                    gap: 6,
                    borderRadius: 20,
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 48, color: context.primary.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'اضغط لالتقاط أو اختيار صورة',
                              style: AppTypography.bodyMedium(isDark: isDark).copyWith(color: context.textMuted),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Submit Button
            if (!auth.isVerificationPending)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('إرسال لطلب التوثيق', style: AppTypography.buttonLabel(isDark: isDark)),
                ),
              ),
            
            if (auth.isVerificationPending)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'طلبك قيد المراجعة حالياً. سيتم إخطارك بمجرد التحديث.',
                        style: AppTypography.bodySmall(isDark: isDark).copyWith(color: Colors.amber.shade700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> status, bool isDark) {
    final statusStr = status['status'] ?? 'pending';
    Color statusColor = Colors.amber;
    String statusLabel = 'قيد الانتظار';
    IconData statusIcon = Icons.hourglass_empty_rounded;

    if (statusStr == 'approved') {
      statusColor = context.primary;
      statusLabel = 'موثق';
      statusIcon = Icons.verified_rounded;
    } else if (statusStr == 'rejected') {
      statusColor = AppColors.error;
      statusLabel = 'مرفوض';
      statusIcon = Icons.cancel_rounded;
    }

    return FadeInSlide(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'حالة التوثيق: $statusLabel',
                  style: AppTypography.bodyLarge(isDark: isDark).copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (status['admin_notes'] != null && statusStr == 'rejected') ...[
              const SizedBox(height: 8),
              Text(
                'سبب الرفض: ${status['admin_notes']}',
                style: AppTypography.bodySmall(isDark: isDark).copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
