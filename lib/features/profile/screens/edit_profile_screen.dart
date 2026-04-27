import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/helpers/image_helper.dart';
import '../../../core/widgets/fade_in_slide.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImageHelper.pickImage(
      context: context,
      source: ImageSource.gallery,
      cropStyle: CropStyle.circle,
      lockAspectRatio: true,
      initAspectRatio: CropAspectRatioPreset.square,
    );
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        currentPassword: _showPasswordFields
            ? _currentPasswordController.text
            : null,
        newPassword: _showPasswordFields ? _newPasswordController.text : null,
        profileImage: _selectedImage,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم تحديث الملف الشخصي بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ??
                    'فشل التحديث، يرجى المحاولة لاحقاً',
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthProvider, dynamic>((p) => p.currentUser);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تعديل الملف الشخصي',
          style: AppTypography.h3(isDark: isDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              FadeInSlide(
                duration: const Duration(milliseconds: 400),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: context.primary.withValues(
                            alpha: 0.1,
                          ),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!) as ImageProvider
                              : (user?.profileImage != null &&
                                        user!.profileImage!.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        user.profileImage!,
                                      )
                                    : null),
                          child:
                              _selectedImage == null &&
                                  (user?.profileImage == null ||
                                      user!.profileImage!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 55,
                                  color: context.primary,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Inputs Section
              FadeInSlide(
                duration: const Duration(milliseconds: 500),
                direction: FadeInSlideDirection.btt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المعلومات الأساسية',
                      style: AppTypography.bodySmall(isDark: isDark).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      style: AppTypography.bodyLarge(isDark: isDark),
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'يرجى إدخال الاسم';
                        }
                        if (v.trim().length < 3) {
                          return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      style: AppTypography.bodyLarge(isDark: isDark),
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Password Toggle Section
              FadeInSlide(
                duration: const Duration(milliseconds: 600),
                direction: FadeInSlideDirection.btt,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border(isDark)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        title: Text(
                          'تغيير كلمة المرور',
                          style: AppTypography.bodyLarge(isDark: isDark),
                        ),
                        trailing: Switch.adaptive(
                          value: _showPasswordFields,
                          onChanged: (v) =>
                              setState(() => _showPasswordFields = v),
                          activeThumbColor: context.primary,
                        ),
                      ),
                      if (_showPasswordFields) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: true,
                                style: AppTypography.bodyLarge(isDark: isDark),
                                decoration: const InputDecoration(
                                  labelText: 'كلمة المرور الحالية',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                validator: (v) =>
                                    _showPasswordFields &&
                                        (v == null || v.isEmpty)
                                    ? 'يرجى إدخال كلمة المرور الحالية'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: true,
                                style: AppTypography.bodyLarge(isDark: isDark),
                                decoration: const InputDecoration(
                                  labelText: 'كلمة المرور الجديدة',
                                  prefixIcon: Icon(Icons.lock_open),
                                ),
                                validator: (v) =>
                                    _showPasswordFields &&
                                        (v == null || v.length < 6)
                                    ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Save Button
              FadeInSlide(
                duration: const Duration(milliseconds: 700),
                direction: FadeInSlideDirection.btt,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'حفظ التغييرات',
                            style: AppTypography.buttonLabel(isDark: isDark),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
