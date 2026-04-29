import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// دوال top-level للـ compute isolate (Dart خالص فقط — بلا Platform Channels)
// ─────────────────────────────────────────────────────────────────────────────

/// ترميز bytes لـ base64 — Dart خالص، آمن في compute
String _encodeBase64Isolate(Uint8List bytes) => base64Encode(bytes);

/// بناء JSON body — Dart خالص، آمن في compute
String _buildJsonIsolate(_JsonBuildParams p) {
  return jsonEncode({
    'system_instruction': {
      'parts': [
        {'text': p.systemPrompt}
      ]
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': 'حلل هذه الصورة وأعطني النتائج بتنسيق JSON فقط بدون أي نص إضافي.'},
          {
            'inline_data': {
              'mime_type': 'image/jpeg',
              'data': p.base64Image,
            }
          }
        ]
      }
    ],
    'generationConfig': {
      'temperature': 0.1,
      'maxOutputTokens': 1024,
      'responseMimeType': 'application/json',
    },
  });
}

class _JsonBuildParams {
  final String systemPrompt;
  final String base64Image;
  _JsonBuildParams({required this.systemPrompt, required this.base64Image});
}

// ─────────────────────────────────────────────────────────────────────────────
// نموذج النتيجة
// ─────────────────────────────────────────────────────────────────────────────

class PlantDiagnosisResult {
  final String plantName;
  final String diseaseType;
  final String diseaseCauses;
  final String treatmentMethods;
  final String severityLevel;
  final String preventionTips;
  final bool isHealthy;
  final String rawResponse;

  const PlantDiagnosisResult({
    required this.plantName,
    required this.diseaseType,
    required this.diseaseCauses,
    required this.treatmentMethods,
    required this.severityLevel,
    required this.preventionTips,
    required this.isHealthy,
    required this.rawResponse,
  });

  factory PlantDiagnosisResult.fromJson(Map<String, dynamic> json, String raw) {
    return PlantDiagnosisResult(
      plantName: json['plantName'] ?? 'غير محدد',
      diseaseType: json['diseaseType'] ?? 'غير محدد',
      diseaseCauses: json['diseaseCauses'] ?? 'غير محدد',
      treatmentMethods: json['treatmentMethods'] ?? 'غير محدد',
      severityLevel: json['severityLevel'] ?? 'غير محدد',
      preventionTips: (json['preventionTips'] is List)
          ? (json['preventionTips'] as List).join('\n')
          : (json['preventionTips'] ?? ''),
      isHealthy: json['isHealthy'] ?? false,
      rawResponse: raw,
    );
  }

  factory PlantDiagnosisResult.fromError(String message) {
    return PlantDiagnosisResult(
      plantName: 'تعذر التحديد',
      diseaseType: 'خطأ في التشخيص',
      diseaseCauses: message,
      treatmentMethods: 'يرجى المحاولة مرة أخرى لاحقاً.',
      severityLevel: 'غير معروفة',
      preventionTips: '',
      isHealthy: false,
      rawResponse: message,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// الخدمة الرئيسية
// ─────────────────────────────────────────────────────────────────────────────

class PlantDiagnosisService {
  static const String _primaryModel = 'gemini-2.0-flash-lite';
  static const String _fallbackModel = 'gemini-2.0-flash';

  static String _buildUrl(String model) =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

  bool _isInitialized = false;
  String? _systemPrompt;

  PlantDiagnosisService();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      final data =
          await rootBundle.loadString('assets/ai/diagnosis_prompt.json');
      final Map<String, dynamic> json = jsonDecode(data);
      _systemPrompt = json['system_instruction'];
    } catch (e) {
      _systemPrompt =
          'أنت خبير زراعي. حلل الصورة وأعد JSON فقط: {"plantName":"...","diseaseType":"...","diseaseCauses":"...","treatmentMethods":"...","severityLevel":"خفيفة","preventionTips":"...","isHealthy":false}';
    }
    debugPrint('PlantDiagnosisService: ready');
  }

  String get _apiKey =>
      dotenv.env['PLANT_DIAGNOSIS_API_KEY'] ??
      dotenv.env['GEMINI_API_KEY'] ??
      '';

  // ─── ضغط الصورة على الخيط الرئيسي (Platform Plugin — لا يعمل في compute) ───
  Future<Uint8List?> _compressImageToFile(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/diag_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // compressAndGetFile: يكتب الملف مباشرة — أقل استهلاكاً للذاكرة من compressWithList
      final result = await FlutterImageCompress.compressAndGetFile(
        // نحتاج مسار الملف الأصلي — نكتب الـ bytes لملف مؤقت أولاً إذا لزم
        await _writeTempFile(imageBytes, tempDir),
        targetPath,
        minWidth: 480,
        minHeight: 480,
        quality: 50,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        debugPrint('PlantDiagnosisService: compression returned null, using original');
        return imageBytes;
      }

      final compressed = await result.readAsBytes();
      debugPrint(
          'Compressed: ${(imageBytes.length / 1024).toStringAsFixed(0)}KB → ${(compressed.length / 1024).toStringAsFixed(0)}KB');

      // حذف الملفات المؤقتة
      try {
        await File(targetPath).delete();
      } catch (_) {}

      return compressed;
    } catch (e) {
      debugPrint('PlantDiagnosisService: compress error $e, using original');
      return imageBytes;
    }
  }

  Future<String> _writeTempFile(Uint8List bytes, Directory dir) async {
    final path = '${dir.path}/src_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// تحليل صورة نبتة — Pipeline آمن بدون crash
  Future<PlantDiagnosisResult> diagnose(Uint8List imageBytes) async {
    await _ensureInitialized();

    if (_apiKey.isEmpty) {
      return PlantDiagnosisResult.fromError('مفتاح API غير موجود.');
    }

    try {
      // ─── Step 1: ضغط على الخيط الرئيسي (Platform Plugin) ───
      debugPrint(
          'Step1: compressing ${(imageBytes.lengthInBytes / 1024).toStringAsFixed(0)}KB...');
      final compressed = await _compressImageToFile(imageBytes);
      if (compressed == null) {
        return PlantDiagnosisResult.fromError('فشل في معالجة الصورة.');
      }

      // ─── Step 2: base64 encoding في compute (Dart خالص — آمن) ───
      debugPrint(
          'Step2: encoding ${(compressed.length / 1024).toStringAsFixed(0)}KB to base64...');
      final base64Image =
          await compute<Uint8List, String>(_encodeBase64Isolate, compressed);

      // ─── Step 3: بناء JSON في compute (Dart خالص — آمن) ───
      debugPrint('Step3: building JSON body...');
      final bodyStr = await compute<_JsonBuildParams, String>(
        _buildJsonIsolate,
        _JsonBuildParams(
          systemPrompt: _systemPrompt ?? '',
          base64Image: base64Image,
        ),
      );

      // ─── Step 4: إرسال الطلب مع fallback عند 429 ───
      debugPrint(
          'Step4: sending ${(bodyStr.length / 1024).toStringAsFixed(0)}KB request...');
      for (final model in [_primaryModel, _fallbackModel]) {
        final uri = Uri.parse('${_buildUrl(model)}?key=$_apiKey');
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: bodyStr,
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          debugPrint('Step4: got 200 from $model');
          return _parseResponse(response.bodyBytes);
        } else if (response.statusCode == 429) {
          debugPrint('PlantDiagnosisService: quota exceeded for $model');
          if (model == _fallbackModel) {
            return PlantDiagnosisResult.fromError(
                'تم تجاوز الحد المجاني. يرجى المحاولة بعد دقيقة.');
          }
          continue;
        } else {
          debugPrint(
              'PlantDiagnosisService HTTP ${response.statusCode}: ${response.body}');
          return PlantDiagnosisResult.fromError(
              'خطأ في الاتصال بالخادم (${response.statusCode}).');
        }
      }
    } catch (e) {
      debugPrint('PlantDiagnosisService FATAL: $e');
      if (e.toString().contains('TimeoutException')) {
        return PlantDiagnosisResult.fromError('انتهت مهلة الاتصال.');
      }
      if (e.toString().contains('SocketException')) {
        return PlantDiagnosisResult.fromError('فشل الاتصال بالإنترنت.');
      }
      return PlantDiagnosisResult.fromError('حدث خطأ غير متوقع.');
    }

    return PlantDiagnosisResult.fromError('تعذر الاتصال بالخادم.');
  }

  PlantDiagnosisResult _parseResponse(List<int> bodyBytes) {
    try {
      final data = jsonDecode(utf8.decode(bodyBytes));
      final rawText =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

      if (rawText.isEmpty) {
        return PlantDiagnosisResult.fromError('لم تُستقبل بيانات من الخادم.');
      }

      final cleanJson = rawText
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);
      return PlantDiagnosisResult.fromJson(jsonData, rawText);
    } catch (e) {
      debugPrint('PlantDiagnosisService parse error: $e');
      return PlantDiagnosisResult.fromError('فشل في تحليل استجابة الخادم.');
    }
  }
}
