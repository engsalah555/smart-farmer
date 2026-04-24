import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/widgets/fade_in_slide.dart';
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
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
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
                            _buildTextField(
                              hint: 'اسم المتجر/الشركة',
                              icon: Icons.store,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),

                            // Register Number
                            _buildTextField(
                              hint: 'رقم السجل التجاري',
                              icon: Icons.badge,
                              isDark: isDark,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const AuthHeader();
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF18181B)
            : const Color(0xFFF8FAFC), // Lighter bg for inputs
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        textAlign: TextAlign.right,
        obscureText: isPassword,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF71717A) : const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder
              .none, // Handled by Container border if needed, or default
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E8F0),
        ),
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
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFF94A3B8),
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
          border: Border.all(
            color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFCBD5E1),
            style: BorderStyle
                .none, // We want dashed... Flutter Border doesn't support dashed easily.
            // Using CustomPaint or just a solid border for now as approximation, or use DottedBorder package if available.
            // Assuming no external packages allowed unless specified, I will use a solid border with dashed styling via a CustomPainter if needed,
            // but for simplicity I'll stick to a styled container.
          ),
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white,
        ),
        // To mimic dashed border, I'll use a specific decoration
        // For now, I'll use a standard border with a different visual style (e.g. slight opacity)
        // because native dashed borders require a package or custom painter.
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: isDark ? const Color(0xFF52525B) : const Color(0xFFCBD5E1),
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

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
    );

    Path dashPath = Path();
    double dashWidth = 8.0;
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
