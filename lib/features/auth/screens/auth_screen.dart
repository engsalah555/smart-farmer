import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/atoms/smart_farm_logo.dart';
import '../../../core/widgets/atoms/pro_max_text_field.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Default to Login
  String userType = 'user'; // 'user' or 'seller'
  String storeType = 'محاصيل'; // Changed to match dropdown options

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _credentialsLoaded = false;

  @override
  void initState() {
    super.initState();
    // تحميل بيانات "تذكرني" بعد تهيئة الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedCredentials();
    });
  }

  /// تحميل بيانات "تذكرني" — البريد فقط لأسباب أمنية
  void _loadSavedCredentials() {
    if (_credentialsLoaded) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.rememberMe && authProvider.savedEmail.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _emailController.text = authProvider.savedEmail;
        // ملاحظة: لا يتم تحميل كلمة المرور لأسباب أمنية
        _credentialsLoaded = true;
      });
    } else {
      _credentialsLoaded = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final authProvider = context.read<AuthProvider>();

    // التحقق من صحة البيانات
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    if (!isLogin && _nameController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى إدخال الاسم الكامل');
      return;
    }

    if (!isLogin &&
        userType == 'seller' &&
        _phoneController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى إدخال رقم الجوال');
      return;
    }

    bool success = false;

    if (isLogin) {
      // تسجيل الدخول
      success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        userType: userType,
        rememberMe: _rememberMe,
      );

      if (success && mounted) {
        context.go('/home');
      }
    } else {
      // التسجيل
      if (userType == 'seller') {
        // تسجيل بائع
        final result = await authProvider.registerSeller(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          storeType: storeType,
        );

        if (result['success'] == true && mounted) {
          if (result['requiresVerification'] == true) {
            // الانتقال إلى شاشة التحقق
            context.push('/merchant_verification');
          } else {
            context.go('/home');
          }
        }
      } else {
        // مستخدم عادي
        success = await authProvider.registerUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (success && mounted) {
          context.go('/home');
        }
      }
    }

    // عرض رسالة الخطأ إن وجدت
    if (!success && mounted && authProvider.errorMessage != null) {
      _showErrorSnackBar(authProvider.errorMessage!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final borderColor = AppColors.border(isDark);
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeInSlide(
              duration: const Duration(milliseconds: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Semantics(
                    label: ' شعار مزرعة الذكية',
                    child: const SmartFarmLogo(width: 150, height: 150),
                  ),
                  const SizedBox(height: 30),

                  // Role Selector (User/Merchant)
                  _buildRoleSelector(isDark),
                  const SizedBox(height: 24),

                  // Form Fields
                  if (!isLogin) ...[
                    // Register Extra Fields
                    _buildTextField(
                      controller: _nameController,
                      hint: 'الاسم الكامل', // Full Name
                      icon: Icons.person_outline,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // Phone Field - Animated & Conditional (Merchant Only)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1.0,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: userType == 'seller'
                          ? Column(
                              key: const ValueKey('seller_inputs'),
                              children: [
                                _buildTextField(
                                  controller: _phoneController,
                                  hint: 'رقم الجوال', // Phone
                                  icon: Icons.phone_android_outlined,
                                  inputType: TextInputType.phone,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildStoreTypeSelector(isDark),
                                const SizedBox(height: 16),
                              ],
                            )
                          : const SizedBox.shrink(key: ValueKey('no_inputs')),
                    ),
                  ],

                  _buildTextField(
                    controller: _emailController,
                    hint: 'البريد الإلكتروني', // Email ID
                    icon: Icons.mail_outline,
                    inputType: TextInputType.emailAddress,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _passwordController,
                    hint: 'كلمة المرور', // Password
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isDark: isDark,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Remember Me & Forgot Password Row
                  Semantics(
                    label: 'تذكرني',
                    child: Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: context.primary,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                        Text(
                          'تذكرني',
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            context.push('/forgot_password');
                          },
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              color: context.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Action Button (Pill Shape)
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            elevation: 4, // Slight elevation for pop
                            shadowColor: context.primary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            disabledBackgroundColor: context.primary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                                  style: context.font18.bold.copyWith(
                                    color: context.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(child: Divider(color: borderColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'أو تسجيل الدخول عبر',
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: borderColor)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          text: 'Google',
                          icon: Icons.g_mobiledata,
                          iconColor: const Color(0xFFEA4335),
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          text: 'Apple',
                          icon: Icons.apple,
                          iconColor: textPrimary,
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? 'ليس لديك حساب؟ ' : '��ديك حساب بالفعل؟ ',
                        style: TextStyle(color: textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => isLogin = !isLogin),
                        child: Text(
                          isLogin ? 'سجل الآن' : 'تسجيل الدخول',
                          style: TextStyle(
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    required bool isDark,
    bool? obscureText,
    VoidCallback? onToggleVisibility,
  }) {
    return ProMaxTextField(
      controller: controller,
      hint: hint,
      icon: icon,
      inputType: inputType,
      isPassword: isPassword,
      obscureText: obscureText ?? false,
      onToggleVisibility: onToggleVisibility,
      borderRadius: 30,
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final fillColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = AppColors.border(isDark);
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector(bool isDark) {
    final containerColor = isDark
        ? AppColors.darkSurface
        : const Color(0xFFF1F5F4);
    final borderColor = AppColors.border(isDark);
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildRoleItem('مستخدم', 'user', isDark, textSecondary),
          _buildRoleItem('بائع', 'seller', isDark, textSecondary),
        ],
      ),
    );
  }

  Widget _buildRoleItem(
    String label,
    String value,
    bool isDark,
    Color secondaryColor,
  ) {
    final isSelected = userType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => userType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? context.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.neutralWhite : secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreTypeSelector(bool isDark) {
    final fillColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = AppColors.border(isDark);
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'تصنيف المتجر',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: storeType,
            icon: Icon(Icons.keyboard_arrow_down, color: context.primary),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              prefixIcon: Icon(
                Icons.store_outlined,
                color: context.primary,
                size: 22,
              ),
            ),
            dropdownColor: fillColor,
            borderRadius: BorderRadius.circular(20),
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            items: const [
              DropdownMenuItem(value: 'بذور', child: Text('بذور')),
              DropdownMenuItem(value: 'اسمدة', child: Text('اسمدة')),
              DropdownMenuItem(value: 'مبيدات', child: Text('مبيدات')),
              DropdownMenuItem(value: 'محاصيل', child: Text('محاصيل')),
              DropdownMenuItem(value: 'معدات', child: Text('معدات')),
              DropdownMenuItem(value: 'المشاتل', child: Text('المشاتل')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => storeType = value);
              }
            },
          ),
        ),
      ],
    );
  }
}
