
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../../core/widgets/atoms/pro_max_text_field.dart';
import '../../../../core/widgets/dashed_border.dart';
import '../widgets/auth_header.dart';
import 'package:go_router/go_router.dart';

class MerchantVerificationScreen extends StatefulWidget {
  const MerchantVerificationScreen({super.key});

  @override
  State<MerchantVerificationScreen> createState() =>
      _MerchantVerificationScreenState();
}

class _MerchantVerificationScreenState
    extends State<MerchantVerificationScreen> {
  String? _selectedActivity;

  @override
  Widget build(BuildContext context) {
    // Determine if we are in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),

            // Content Section - slight negative margin to overlap header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeInSlide(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: isDark
                              ? Border.all(
                                  color: AppColors.darkBorder.withValues(
                                    alpha: 0.5,
                                  ),
                                )
                              : Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'توثيق حساب التاجر', // Merchant Verification
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),

                            // Store Name
                            const ProMaxTextField(
                              hint: 'اسم المتجر/الشركة',
                              icon: Icons.store,
                              borderRadius: 16,
                            ),
                            const SizedBox(height: 16),

                            // Register Number
                            const ProMaxTextField(
                              hint: 'رقم السجل التجاري',
                              icon: Icons.badge,
                              borderRadius: 16,
                            ),
                            const SizedBox(height: 16),

                            // Activity Dropdown
                            _buildDropdown(isDark),
                            const SizedBox(height: 16),

                            // File Upload
                            _buildFileUpload(isDark),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF76C748),
                                      Color(0xFF4A9B2B),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF76C748,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle Verification Submission
                                    context.pop(); // Go back or to success
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'إرسال لطلب التوثيق',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Back to Login
                      TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text('العودة لتسجيل الدخول'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const AuthHeader();
  }


  Widget _buildDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedActivity,
          hint: Row(
            children: [
              Icon(Icons.category, color: Colors.grey.shade400, size: 22),
              const SizedBox(width: 12),
              Text(
                'نوع النشاط التجاري',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: Colors.grey.shade400),
          items:
              const [
                DropdownMenuItem(
                  value: 'seeds',
                  child: Text('بيع البذور والأسمدة'),
                ),
                DropdownMenuItem(
                  value: 'equipment',
                  child: Text('المعدات الزراعية'),
                ),
                DropdownMenuItem(
                  value: 'consulting',
                  child: Text('استشارات زراعية'),
                ),
                DropdownMenuItem(
                  value: 'wholesale',
                  child: Text('تجارة الجملة'),
                ),
              ].map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item.value,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: item.child,
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedActivity = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFileUpload(bool isDark) {
    return InkWell(
      onTap: () {
        // Handle file upload
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.surface.withValues(alpha: 0.5),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: context.border,
            strokeWidth: 2,
            gap: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Icon(Icons.add_a_photo, size: 32, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'تحميل صورة السجل',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
