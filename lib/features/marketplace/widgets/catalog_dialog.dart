import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm2/core/helpers/image_helper.dart';
import 'package:smart_farm2/core/models/catalog_model.dart';
import 'package:smart_farm2/core/theme/app_colors.dart';
import 'package:smart_farm2/core/widgets/atoms/custom_image.dart';
import 'package:smart_farm2/features/marketplace/providers/seller_provider.dart';

class CatalogDialog extends StatefulWidget {
  final CatalogModel? catalog;

  const CatalogDialog({super.key, this.catalog});

  static void show(BuildContext context, {CatalogModel? catalog}) {
    showDialog(
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.catalog != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEditing ? 'تعديل الكتالوج' : 'إضافة كتالوج جديد',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Picker Area
              GestureDetector(
                onTap: () async {
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
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: localImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            File(localImagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : (isEditing &&
                            widget.catalog!.imageUrl != null &&
                            widget.catalog!.imageUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CustomImage(
                            imageUrl: widget.catalog!.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'صورة الكتالوج (اختياري)',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الكتالوج (مثل: بذور صيفية)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف قصير (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final provider = context.read<SellerProvider>();
              context.pop(); // close dialog first

              bool success;
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
                          ? (isEditing
                                ? 'تم تحديث الكتالوج'
                                : 'تمت إضافة الكتالوج')
                          : 'حدث خطأ ما',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة'),
        ),
      ],
    );
  }
}
