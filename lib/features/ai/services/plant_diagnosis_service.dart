import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
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

  factory PlantDiagnosisResult.fromJson(Map<String, dynamic> json, String raw) {
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
          {
            'text':
                'حلل هذه الصورة كخبير زراعي محترف. قدم تشخيصاً دقيقاً وخطوات علاجية عملية. يجب أن تكون النتيجة بتنسيق JSON حصرياً.'
          },
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
// Service
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
استخدم لغة احترافية ومباشرة.
''';
    }
    debugPrint('PlantDiagnosisService: ready with hardened prompt');
  }

  String get _apiKey =>
      dotenv.env['PLANT_DIAGNOSIS_API_KEY'] ??
      dotenv.env['GEMINI_API_KEY'] ??
      '';

  Future<Uint8List?> _compressImageToFile(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/diag_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        await _writeTempFile(imageBytes, tempDir),
        targetPath,
        minWidth: 640,
        minHeight: 640,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (result == null) return imageBytes;
      final compressed = await result.readAsBytes();

      try {
        await File(targetPath).delete();
      } catch (_) {}

      return compressed;
    } catch (e) {
      debugPrint('PlantDiagnosisService: compress error $e');
      return imageBytes;
    }
  }

  Future<String> _writeTempFile(Uint8List bytes, Directory dir) async {
    final path = '${dir.path}/src_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  Future<PlantDiagnosisResult> diagnose(Uint8List imageBytes) async {
    await _ensureInitialized();

    if (_apiKey.isEmpty) {
      return PlantDiagnosisResult.fromError('مفتاح API غير موجود.');
    }

    try {
      final compressed = await _compressImageToFile(imageBytes);
      if (compressed == null) {
        return PlantDiagnosisResult.fromError('فشل في معالجة الصورة.');
      }

      final base64Image =
          await compute<Uint8List, String>(_encodeBase64Isolate, compressed);

      final bodyStr = await compute<_JsonBuildParams, String>(
        _buildJsonIsolate,
        _JsonBuildParams(
          systemPrompt: _systemPrompt ?? '',
          base64Image: base64Image,
        ),
      );

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
          return _parseResponse(response.bodyBytes);
        } else if (response.statusCode == 429) {
          if (model == _fallbackModel) {
            return PlantDiagnosisResult.fromError(
                'تم تجاوز الحد المجاني. يرجى المحاولة بعد دقيقة.');
          }
          continue;
        } else {
          return PlantDiagnosisResult.fromError(
              'خطأ في الاتصال بالخادم (${response.statusCode}).');
        }
      }
    } catch (e) {
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
      return PlantDiagnosisResult.fromError('فشل في تحليل استجابة الخادم.');
    }
  }
}
