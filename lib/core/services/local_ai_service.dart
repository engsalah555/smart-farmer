import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class LocalAIService {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const String modelPath = 'assets/models/mobilenet_v3.tflite';
  static const String labelsPath = 'assets/models/labels.txt';

  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      debugPrint('TFLite model loaded successfully.');

      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();
      debugPrint('Labels loaded: ${_labels?.length} items.');
    } catch (e) {
      debugPrint('Error loading TFLite model or labels: $e');
      _interpreter = null;
      _labels = null;
    }
  }

  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      return {
        'success': false,
        'message': 'نموذج الذكاء الاصطناعي غير جاهز بعد',
      };
    }

    try {
      // 1. Read the image and decode it
      final imageData = await File(imagePath).readAsBytes();
      img.Image? originalImage = img.decodeImage(imageData);

      if (originalImage == null) {
        return {'success': false, 'message': 'لا يمكن قراءة الصورة'};
      }

      // 2. Resize to MobileNetV3 expected dimensions (e.g., 224x224)
      img.Image resizedImage = img.copyResize(
        originalImage,
        width: 224,
        height: 224,
      );

      // 3. Convert image to a 3D float array [1, 224, 224, 3] normalized between 0 and 1
      var input = List.generate(
        1,
        (i) => List.generate(
          224,
          (y) => List.generate(224, (x) {
            final pixel = resizedImage.getPixelSafe(x, y);
            return [
              pixel.r.toDouble() / 255.0,
              pixel.g.toDouble() / 255.0,
              pixel.b.toDouble() / 255.0,
            ];
          }),
        ),
      );

      // 4. Create output container
      var output = List<List<double>>.filled(
        1,
        List<double>.filled(_labels!.length, 0.0),
      );

      // 5. Run inference
      _interpreter!.run(input, output);

      // 6. Parse results
      final List<double> results = output[0];
      double maxScore = 0;
      int maxIndex = -1;

      for (int i = 0; i < results.length; i++) {
        if (results[i] > maxScore) {
          maxScore = results[i];
          maxIndex = i;
        }
      }

      if (maxIndex != -1) {
        String diseaseName = _labels![maxIndex];
        return {
          'success': true,
          'disease': diseaseName,
          'confidence': maxScore * 100, // as percentage
        };
      } else {
        return {'success': false, 'message': 'فشل في تحليل الصورة'};
      }
    } catch (e) {
      debugPrint('TFLite Error: $e');
      return {'success': false, 'message': 'حدث خطأ أثناء تحليل الصورة محلياً'};
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
