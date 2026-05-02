import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../marketplace/providers/seller_provider.dart';
import '../../../core/models/store_model.dart';
import '../../../core/helpers/image_helper.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/atoms/unified_profile_avatar.dart';

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

  // Store Fields
  late TextEditingController _storeNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  File? _coverFile;
  double? _latitude;
  double? _longitude;

  File? _selectedImage;
  bool _isLoading = false;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');

    final store = context.read<SellerProvider>().myStore;
    _storeNameController = TextEditingController(text: store?.name ?? '');
    _descriptionController = TextEditingController(
      text: store?.description ?? '',
    );
    _addressController = TextEditingController(text: store?.location ?? '');
    _latitude = store?.latitude;
    _longitude = store?.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _storeNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
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

  Future<void> _pickCoverImage() async {
    final image = await ImageHelper.pickImage(
      context: context,
      source: ImageSource.gallery,
      cropStyle: CropStyle.rectangle,
      lockAspectRatio: true,
      initAspectRatio: CropAspectRatioPreset.ratio16x9,
      aspectRatios: [
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio3x2,
      ],
    );
    if (image != null) {
      setState(() => _coverFile = image);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خدمات الموقع غير مفعلة. يرجى تفعيلها من الإعدادات.'),
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض إذن الوصول للموقع.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'أذونات الموقع مرفوضة نهائياً. يرجى تفعيلها من إعدادات التطبيق.',
            ),
          ),
        );
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تحديد الموقع بنجاح')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في الحصول على الموقع: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final isSeller = authProvider.currentUser?.isSeller ?? false;

      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        currentPassword: _showPasswordFields
            ? _currentPasswordController.text
            : null,
        newPassword: _showPasswordFields ? _newPasswordController.text : null,
        profileImage: _selectedImage,
      );

      bool storeSuccess = true;
      String? storeError;
      if (success && isSeller) {
        if (!mounted) return;
        final sellerProvider = context.read<SellerProvider>();
        storeSuccess = await sellerProvider.updateStoreInfo({
          'store_name': _storeNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'address': _addressController.text.trim(),
          'latitude': _latitude,
          'longitude': _longitude,
        }, coverImagePath: _coverFile?.path);
        storeError = sellerProvider.errorMessage;
      }

      if (mounted) {
        if (success && storeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم تحديث البيانات بنجاح'),
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
                (!success)
                    ? (authProvider.errorMessage ?? 'فشل تحديث الملف الشخصي')
                    : (storeError ?? 'فشل تحديث المتجر'),
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
    final isSeller = user?.isSeller ?? false;
    final store = context.select<SellerProvider, StoreModel?>((p) => p.myStore);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasCoverNet =
        store != null &&
        store.coverImage.isNotEmpty &&
        store.coverImage.startsWith('http');

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
                      UnifiedProfileAvatar(
                        imageUrl: user?.profileImage,
                        localImage: _selectedImage,
                        radius: 55,
                        borderWidth: 2,
                        hasShadow: false,
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
              const SizedBox(height: 32),

              if (isSeller) ...[
                FadeInSlide(
                  duration: const Duration(milliseconds: 650),
                  direction: FadeInSlideDirection.btt,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات المتجر',
                        style: AppTypography.bodySmall(isDark: isDark).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Cover Image Section
                      GestureDetector(
                        onTap: _pickCoverImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border(isDark)),
                            image: _coverFile != null
                                ? DecorationImage(
                                    image: FileImage(_coverFile!),
                                    fit: BoxFit.cover,
                                  )
                                : (hasCoverNet
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            store.coverImage,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                          ),
                          child: _coverFile == null && !hasCoverNet
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'اضغط لاختيار صورة الغلاف',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Fields
                      TextFormField(
                        controller: _storeNameController,
                        style: AppTypography.bodyLarge(isDark: isDark),
                        decoration: const InputDecoration(
                          labelText: 'اسم المتجر',
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'يرجى إدخال اسم المتجر'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        style: AppTypography.bodyLarge(isDark: isDark),
                        decoration: const InputDecoration(
                          labelText: 'وصف المتجر',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        style: AppTypography.bodyLarge(isDark: isDark),
                        decoration: const InputDecoration(
                          labelText: 'عنوان المتجر',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Location selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(isDark)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, color: context.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'الموقع الجغرافي (GPS)',
                                    style: AppTypography.bodyLarge(
                                      isDark: isDark,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _getCurrentLocation,
                                  icon: const Icon(Icons.my_location, size: 16),
                                  label: const Text('تحديد موقعي الآن'),
                                ),
                              ],
                            ),
                            if (_latitude != null && _longitude != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'الإحداثيات: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'الموقع غير محدد بدقة على الخريطة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],

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
