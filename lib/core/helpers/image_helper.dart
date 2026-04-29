import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/ai/widgets/camera_view.dart';
import '../constants.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera, crop it, and compress it
  static Future<File?> pickImage({
    required BuildContext context,
    required ImageSource source,
    bool cropImage = false,
    int compressQuality = 75,
    CropStyle cropStyle = CropStyle.rectangle,
    List<CropAspectRatioPreset>? aspectRatios,
    bool lockAspectRatio = false,
    CropAspectRatioPreset initAspectRatio = CropAspectRatioPreset.original,
  }) async {
    try {
      // 1. Pick Image
      XFile? pickedFile;
      if (source == ImageSource.camera) {
        final cameras = await availableCameras();
        if (cameras.isEmpty) return null;
        if (!context.mounted) return null;
        
        pickedFile = await Navigator.push<XFile>(
          context,
          MaterialPageRoute(
            builder: (_) => CameraView(cameras: cameras),
          ),
        );
      } else {
        pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
        );
      }

      if (pickedFile == null) return null;

      String filePath = pickedFile.path;

      // 2. Crop Image
      if (cropImage) {
        if (!context.mounted) return null;
        
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: filePath,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'تعديل الصورة',
              toolbarColor: context.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: initAspectRatio,
              lockAspectRatio: lockAspectRatio,
              cropStyle: cropStyle,
              aspectRatioPresets:
                  aspectRatios ??
                  [
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9,
                  ],
            ),
            IOSUiSettings(
              title: 'تعديل الصورة',
              cropStyle: cropStyle,
              aspectRatioLockEnabled: lockAspectRatio,
              resetAspectRatioEnabled: !lockAspectRatio,
              aspectRatioPresets:
                  aspectRatios ??
                  [
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9,
                  ],
            ),
          ],
        );

        if (croppedFile == null) return null; // Cancelled cropping
        filePath = croppedFile.path;
      }

      // 3. Compress Image
      return await _compressImage(File(filePath), compressQuality);
    } catch (e) {
      debugPrint('Error picking and processing image: $e');
      return null;
    }
  }

  static Future<File?> _compressImage(File file, int quality) async {
    final tempDir = await getTemporaryDirectory();
    final path = file.absolute.path;
    final outPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

    // Compress
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      path,
      outPath,
      quality: quality,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      return File(result.path);
    }
    return file; // Return original if compression fails
  }
}
