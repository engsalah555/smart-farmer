import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/atoms/pro_max_text_field.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (_emailController.text.trim().isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      _showMessage('تم إرسال رمز التحقق إلى بريدك الإلكتروني', isError: false);
      // يمكن الانتقال إلى شاشة إدخال الرمز هنا
    } else if (mounted && authProvider.errorMessage != null) {
      _showMessage(authProvider.errorMessage!, isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(),
        ),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Reusable Header
            const AuthHeader(
              title: 'نسيت كلمة السر',
              subtitle: 'استعد حسابك بسهولة',
              showBackButton: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeInSlide(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
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
                              'أدخل بريدك الإلكتروني',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'سنرسل لك رمزاً للتحقق إلى بريدك الإلكتروني لاستعادة كلمة المرور.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Email Input
                            ProMaxTextField(
                              controller: _emailController,
                              hint: 'البريد الإلكتروني',
                              icon: Icons.mail_outline,
                              inputType: TextInputType.emailAddress,
                              borderRadius: 30,
                            ),
                            const SizedBox(height: 24),

                            // Send Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleSendCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primary,
                                  elevation: 4,
                                  shadowColor: context.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'إرسال الرمز',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
