import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/atoms/smart_farm_logo.dart';
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
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(),
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force light mode for this design if strictly "Minimal White",
    // or adapt carefully. The prompt said "Minimal White", implying light theme is dominant.
    // However, I will support dark mode by checking brightness but keeping the layout clean.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181E14) : Colors.white,
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
                  // Enlarged Logo as requested
                  const SmartFarmLogo(width: 150, height: 150),
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
                  Row(
                    children: [
                      // Remember Me Checkbox
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: Colors.grey.shade400,
                          checkboxTheme: CheckboxThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                      ),
                      Text(
                        'تذكرني', // Remember me
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      // Forgot Password Link
                      TextButton(
                        onPressed: () {
                          context.push('/forgot_password');
                        },
                        child: const Text(
                          'نسيت كلمة المرور؟', // Forgot Password?
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
                            backgroundColor: AppColors.primary,
                            elevation: 4, // Slight elevation for pop
                            shadowColor: AppColors.primary.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.6),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // "Or login with" Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'أو تسجيل الدخول عبر',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          text: 'Google',
                          icon: Icons.g_mobiledata,
                          iconColor: Colors.red, // Google Red
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          text: 'Apple',
                          icon: Icons.apple,
                          iconColor: isDark ? Colors.white : Colors.black,
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Switch Auth Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? 'ليس لديك حساب؟ ' : 'لديك حساب بالفعل؟ ',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => isLogin = !isLogin),
                        child: Text(
                          isLogin ? 'سجل الآن' : 'تسجيل الدخول',
                          style: const TextStyle(
                            color: AppColors.primary,
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
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : Colors.white,
        borderRadius: BorderRadius.circular(30), // Pill shape from design
        border: Border.all(
          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscureText ?? false,
        textAlign: TextAlign.right, // Arabic alignment
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary, // Green Icon
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (obscureText ?? false)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF27272A) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
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
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildRoleItem('مستخدم', 'user', isDark),
          _buildRoleItem('بائع', 'seller', isDark),
        ],
      ),
    );
  }

  Widget _buildRoleItem(String label, String value, bool isDark) {
    final isSelected = userType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => userType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreTypeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'تصنيف المتجر',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF27272A) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E8F0),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: storeType,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              prefixIcon: const Icon(
                Icons.store_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            dropdownColor: isDark ? const Color(0xFF27272A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
               // Ensure font is correct
            ),
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
