import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm2/core/helpers/image_helper.dart';
import 'package:smart_farm2/core/models/catalog_model.dart';
import 'package:smart_farm2/core/theme/app_colors.dart';
import 'package:smart_farm2/core/widgets/app_fonts.dart';
import 'package:smart_farm2/core/widgets/atoms/custom_image.dart';
import 'package:smart_farm2/features/marketplace/providers/seller_provider.dart';

class CatalogDialog extends StatefulWidget {
  final CatalogModel? catalog;

  const CatalogDialog({super.key, this.catalog});

  static Future<void> show(BuildContext context, {CatalogModel? catalog}) {
    return showDialog(
      context: context,
      builder: (context) => CatalogDialog(catalog: catalog),
    );
  }

  @override
  State<CatalogDialog> createState() => _CatalogDialogState();
}

class _CatalogDialogState extends State<CatalogDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  String? localImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.catalog?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.catalog?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImageHelper.pickImage(
      context: context,
      source: ImageSource.gallery,
      cropStyle: CropStyle.rectangle,
      aspectRatios: [CropAspectRatioPreset.ratio4x3],
    );
    if (image != null) {
      setState(() {
        localImagePath = image.path;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<SellerProvider>();
    context.pop();

    bool success;
    final isEditing = widget.catalog != null;
    if (isEditing) {
      success = await provider.updateCatalog(
        widget.catalog!.id,
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        imagePath: localImagePath,
      );
    } else {
      success = await provider.createCatalog(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        imagePath: localImagePath,
      );
    }

    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (isEditing ? 'تم تحديث الكتالوج' : 'تمت إضافة الكتالوج')
                : 'حدث خطأ ما',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.catalog != null;

    return Dialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isEditing
                            ? Icons.edit_note_rounded
                            : Icons.add_box_rounded,
                        color: context.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing
                                ? 'تعديل تفاصيل الكتالوج'
                                : 'إنشاء كتالوج منتجات',
                            style: context.font20.bold.copyWith(
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing
                                ? 'تحديث المعلومات والصورة الخاصة بالكتالوج'
                                : 'نظّم منتجاتك في مجموعات ليسهل الوصول إليها',
                            style: context.font12.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.border, width: 1.5),
                    ),
                    child: localImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(localImagePath!),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : (isEditing &&
                              widget.catalog!.imageUrl != null &&
                              widget.catalog!.imageUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CustomImage(
                                  imageUrl: widget.catalog!.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                                Container(color: Colors.black26),
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'تغيير الصورة',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: context.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 32,
                                  color: context.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'صورة الغلاف (اختياري)',
                                style: context.font14.semiBold.copyWith(
                                  color: context.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'اضغط لاختيار صورة تعريفية للكتالوج',
                                style: context.font10.copyWith(
                                  color: context.textMuted,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  style: context.font14.medium.copyWith(
                    color: context.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'اسم الكتالوج',
                    hintText: 'مثال: بذور صيفية 2024',
                    filled: true,
                    fillColor: context.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.primary, width: 2),
                    ),
                    labelStyle: context.font14.copyWith(
                      color: context.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.label_outline_rounded,
                      color: context.primary,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'يرجى إدخال الاسم'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: context.font14.medium.copyWith(
                    color: context.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'وصف الكتالوج',
                    hintText: 'اكتب وصفاً مختصراً لمحتويات هذا الكتالوج',
                    filled: true,
                    fillColor: context.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.primary, width: 2),
                    ),
                    labelStyle: context.font14.copyWith(
                      color: context.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color: context.primary,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: context.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: context.font14.bold.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing
                                        ? Icons.save_rounded
                                        : Icons.add_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEditing
                                        ? 'حفظ التغييرات'
                                        : 'إنشاء الكتالوج',
                                    style: context.font14.bold.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
