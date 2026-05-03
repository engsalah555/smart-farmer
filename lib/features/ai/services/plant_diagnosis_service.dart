import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums & Models
// ─────────────────────────────────────────────────────────────────────────────

enum DiagnosisSeverity {
  low,
  medium,
  high,
  unknown;

  static DiagnosisSeverity fromString(String? value) {
    if (value == null) return unknown;
    final val = value.toLowerCase();
    if (val.contains('خفيف') || val.contains('low')) return low;
    if (val.contains('متوسط') || val.contains('medium')) return medium;
    if (val.contains('عال') || val.contains('خطير') || val.contains('high')) {
      return high;
    }
    return unknown;
  }

  String get label {
    switch (this) {
      case low:
        return 'إصابة خفيفة';
      case medium:
        return 'إصابة متوسطة';
      case high:
        return 'إصابة خطيرة';
      case unknown:
        return 'غير محددة';
    }
  }
}

class PlantDiagnosisResult {
  final String plantName;
  final String diseaseType;
  final String diseaseCauses;
  final String treatmentMethods;
  final DiagnosisSeverity severity;
  final List<String> preventionTips;
  final bool isHealthy;
  final String rawResponse;

  const PlantDiagnosisResult({
    required this.plantName,
    required this.diseaseType,
    required this.diseaseCauses,
    required this.treatmentMethods,
    required this.severity,
    required this.preventionTips,
    required this.isHealthy,
    required this.rawResponse,
  });

  factory PlantDiagnosisResult.fromJson(
      Map<String, dynamic> json, String raw) {
    return PlantDiagnosisResult(
      plantName: json['plantName'] ?? 'غير محدد',
      diseaseType: json['diseaseType'] ?? 'غير محدد',
      diseaseCauses: json['diseaseCauses'] ?? 'غير محدد',
      treatmentMethods: json['treatmentMethods'] ?? 'غير محدد',
      severity: DiagnosisSeverity.fromString(json['severityLevel']),
      preventionTips: (json['preventionTips'] is List)
          ? List<String>.from(json['preventionTips'])
          : [],
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
      severity: DiagnosisSeverity.unknown,
      preventionTips: [],
      isHealthy: false,
      rawResponse: message,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top-level Isolate Functions
// ─────────────────────────────────────────────────────────────────────────────

String _encodeBase64Isolate(Uint8List bytes) => base64Encode(bytes);

// ─────────────────────────────────────────────────────────────────────────────
// Service — يستخدم Grok Vision API
// ─────────────────────────────────────────────────────────────────────────────

class PlantDiagnosisService {
  bool _isInitialized = false;
  String? _systemPrompt;

  // الإعدادات الافتراضية
  String _currentBaseUrl = 'https://api.x.ai/v1/chat/completions';
  String _currentPrimaryModel = 'grok-2-vision-1212';
  String _currentFallbackModel = 'grok-2';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  PlantDiagnosisService();

  String get _apiKey {
    // الأولوية للمفتاح "smart_farmar2" مع تنظيف أي مسافات
    final key = (dotenv.env['smart_farmar2'] ??
                 dotenv.env['GROK_API_KEY'] ??
                 dotenv.env['XAI_API_KEY'] ??
                 dotenv.env['PLANT_DIAGNOSIS_API_KEY'] ??
                 '').trim();
    return key;
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final key = _apiKey;
    // اكتشاف المزود: Groq يحتوي على gsk
    if (key.startsWith('gsk_') || key.contains('gsk')) {
      _currentBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
      _currentPrimaryModel = 'llama-3.2-11b-vision-preview';
      _currentFallbackModel = 'llama-3.2-90b-vision-preview';
      debugPrint('PlantDiagnosisService: Identified Groq Provider');
    } else {
      _currentBaseUrl = 'https://api.x.ai/v1/chat/completions';
      _currentPrimaryModel = 'grok-2-vision-1212';
      _currentFallbackModel = 'grok-2';
      debugPrint('PlantDiagnosisService: Identified xAI Provider');
    }

    try {
      final data = await rootBundle.loadString('assets/ai/diagnosis_prompt.json');
      final Map<String, dynamic> json = jsonDecode(data);
      _systemPrompt = json['system_instruction'];
    } catch (e) {
      debugPrint('PlantDiagnosisService: Error loading prompt, using default. $e');
      _systemPrompt = '''
أنت خبير وقاية نباتات عالمي. مهمتك تحليل صور النباتات وتقديم تقرير علمي دقيق.
يجب أن تلتزم بتنسيق JSON التالي حصراً:
{
  "plantName": "اسم النبتة الشائع بالعربية",
  "isHealthy": true/false,
  "diseaseType": "اسم المرض بالعربية (أو 'سليمة')",
  "diseaseCauses": "شرح موجز للأسباب",
  "severityLevel": "Low/Medium/High",
  "treatmentMethods": "خطوات علاجية مفصلة وعملية",
  "preventionTips": ["نصيحة 1", "نصيحة 2", "نصيحة 3"]
}
أجب بـ JSON فقط بدون أي نص إضافي.
''';
    }
    debugPrint('PlantDiagnosisService: Ready (Model: $_currentPrimaryModel)');
  }

  Future<Uint8List?> _compressImageToFile(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final srcPath = '${tempDir.path}/src_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = '${tempDir.path}/diag_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(srcPath).writeAsBytes(imageBytes);

      final result = await FlutterImageCompress.compressAndGetFile(
        srcPath,
        targetPath,
        minWidth: 640,
        minHeight: 640,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      // تنظيف
      try { await File(srcPath).delete(); } catch (_) {}

      if (result == null) return imageBytes;
      final compressed = await result.readAsBytes();
      try { await File(targetPath).delete(); } catch (_) {}

      return compressed;
    } catch (e) {
      debugPrint('PlantDiagnosisService: Compress error $e');
      return imageBytes;
    }
  }

  Future<PlantDiagnosisResult> diagnose(Uint8List imageBytes) async {
    await _ensureInitialized();

    if (_apiKey.isEmpty) {
      return PlantDiagnosisResult.fromError('مفتاح API غير موجود.');
    }

    try {
      final compressed = await _compressImageToFile(imageBytes);
      if (compressed == null) return PlantDiagnosisResult.fromError('فشل معالجة الصورة.');

      final base64Image = base64Encode(compressed);

      final messages = [
        if (_systemPrompt != null) {'role': 'system', 'content': _systemPrompt!},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'حلل هذه الصورة كخبير زراعي وقدم النتيجة بتنسيق JSON فقط.'},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
            }
          ]
        }
      ];

      for (final model in [_currentPrimaryModel, _currentFallbackModel]) {
        try {
          final response = await _dio.post<Map<String, dynamic>>(
            _currentBaseUrl,
            data: {
              'model': model,
              'messages': messages,
              'temperature': 0.1,
              'response_format': {'type': 'json_object'},
            },
            options: Options(
              headers: {'Authorization': 'Bearer $_apiKey'},
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            final rawText = response.data!['choices']?[0]?['message']?['content'] as String?;
            if (rawText == null || rawText.isEmpty) {
              return PlantDiagnosisResult.fromError('رد فارغ من الخادم.');
            }
            return _parseResponse(rawText);
          }
        } on DioException catch (e) {
          final errorBody = e.response?.data?.toString() ?? e.message;
          debugPrint('PlantDiagnosisService Error ($model): $errorBody');
          
          if (e.response?.statusCode == 429) {
            return PlantDiagnosisResult.fromError('تم تجاوز حد الطلبات للمستوى المجاني حالياً.');
          }
          
          if (model == _currentFallbackModel) {
            return PlantDiagnosisResult.fromError('فشل الاتصال بالخادم (${e.response?.statusCode}).');
          }
        }
      }
    } catch (e) {
      debugPrint('PlantDiagnosisService Unexpected error: $e');
      return PlantDiagnosisResult.fromError('حدث خطأ غير متوقع.');
    }

    return PlantDiagnosisResult.fromError('تعذر الحصول على تشخيص حالياً.');
  }

  PlantDiagnosisResult _parseResponse(String rawText) {
    try {
      final cleanJson = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final start = cleanJson.indexOf('{');
      final end = cleanJson.lastIndexOf('}');
      if (start == -1 || end == -1) {
        return PlantDiagnosisResult.fromError('تنسيق الرد غير صالح.');
      }

      final jsonStr = cleanJson.substring(start, end + 1);
      final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
      return PlantDiagnosisResult.fromJson(jsonData, rawText);
    } catch (e) {
      return PlantDiagnosisResult.fromError('فشل في تحليل البيانات المستلمة.');
    }
  }
}

