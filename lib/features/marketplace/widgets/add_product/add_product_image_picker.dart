import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/constants.dart';
import '../../../../core/helpers/image_helper.dart';

class AddProductImagePicker extends StatelessWidget {
  final List<String> selectedImages;
  final Function(String) onImageAdded;
  final Function(int) onImageRemoved;
  final Function(String, {bool isError}) showSnackBar;

  const AddProductImagePicker({
    super.key,
    required this.selectedImages,
    required this.onImageAdded,
    required this.onImageRemoved,
    required this.showSnackBar,
  });

  Future<void> _pickImage(BuildContext context, {required ImageSource source}) async {
    if (selectedImages.length >= 5) {
      showSnackBar('يمكنك إضافة 5 صور كحد أقصى', isError: true);
      return;
    }
    try {
      final image = await ImageHelper.pickImage(
        context: context,
        source: source,
        cropStyle: CropStyle.rectangle,
        lockAspectRatio: true,
        initAspectRatio: CropAspectRatioPreset.square,
        aspectRatios: const [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
        ],
      );
      if (image != null) {
        onImageAdded(image.path);
      }
    } catch (_) {
      showSnackBar(
        source == ImageSource.gallery ? 'فشل في اختيار الصورة' : 'فشل في التقاط الصورة',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(left: 12),
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: selectedImages[index].startsWith('http')
                          ? Image.network(
                              selectedImages[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImages[index]),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: GestureDetector(
                        onTap: () => onImageRemoved(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _buildImageButton(
                context,
                icon: Icons.photo_library_outlined,
                label: 'من المعرض',
                onTap: () => _pickImage(context, source: ImageSource.gallery),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImageButton(
                context,
                icon: Icons.camera_alt_outlined,
                label: 'التقاط صورة',
                onTap: () => _pickImage(context, source: ImageSource.camera),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'يمكنك إضافة حتى 5 صور (${selectedImages.length}/5)',
          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  Widget _buildImageButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
