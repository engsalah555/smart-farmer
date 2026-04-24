import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/constants.dart';
import '../../../core/helpers/image_helper.dart';
import '../../../core/models/store_model.dart';
import '../providers/seller_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;

  File? _logoFile;
  File? _coverFile;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // Use read to prevent rebuilding during initialization
    final provider = context.read<SellerProvider>();
    final store = provider.myStore;

    _nameController = TextEditingController(text: store?.name ?? '');
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
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final image = await ImageHelper.pickImage(
      context: context,
      source: ImageSource.gallery,
      cropStyle: isLogo ? CropStyle.circle : CropStyle.rectangle,
      lockAspectRatio: true,
      initAspectRatio: isLogo
          ? CropAspectRatioPreset.square
          : CropAspectRatioPreset.ratio16x9,
      aspectRatios: isLogo
          ? [CropAspectRatioPreset.square]
          : [CropAspectRatioPreset.ratio16x9, CropAspectRatioPreset.ratio3x2],
    );

    if (image != null) {
      setState(() {
        if (isLogo) {
          _logoFile = image;
        } else {
          _coverFile = image;
        }
      });
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

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SellerProvider>();

    // Validate we're picking image files correctly
    final success = await provider.updateStoreInfo(
      {
        'store_name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
      },
      logoPath: _logoFile?.path,
      coverImagePath: _coverFile?.path,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث إعدادات المتجر بنجاح')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في التحديث: ${provider.errorMessage ?? "خطأ غير معروف"}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.select<SellerProvider, StoreModel?>(
      (p) => p.myStore,
    );
    final isLoading = context.select<SellerProvider, bool>(
      (p) => p.isLoading,
    );

    if (store == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('إعدادات المتجر')),
        body: const Center(child: Text('لا يوجد متجر مرتبط بحسابك.')),
      );
    }

    final hasLogoNet = store.logo.isNotEmpty && store.logo.startsWith('http');
    final hasCoverNet =
        store.coverImage.isNotEmpty && store.coverImage.startsWith('http');

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات متجري')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cover Image Section
                    GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
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
                            ? const Center(
                                child: Text(
                                  'اضغط لاختيار صورة الغلاف',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Logo Section
                    Center(
                      child: GestureDetector(
                        onTap: () => _pickImage(true),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _logoFile != null
                              ? FileImage(_logoFile!) as ImageProvider
                              : (hasLogoNet
                                    ? CachedNetworkImageProvider(store.logo)
                                    : null),
                          child: _logoFile == null && !hasLogoNet
                              ? const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Catalog Management Link
                    _buildCatalogLink(context),
                    const SizedBox(height: 24),
                    // Fields
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المتجر',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'يرجى إدخال اسم المتجر'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'وصف المتجر',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان المتجر',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Location selection
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'الموقع الجغرافي (GPS)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
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
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: _saveSettings,
                      child: const Text(
                        'حفظ التغييرات',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCatalogLink(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        onTap: () => context.push('/catalog_manager'),
        leading: const Icon(
          Icons.collections_bookmark_outlined,
          color: AppColors.primary,
        ),
        title: const Text(
          'إدارة الكتالوجات (التصنيفات)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('نظم منتجاتك في مجموعات متنوعة'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
