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
  critical,
  unknown;

  static DiagnosisSeverity fromString(String? value) {
    if (value == null) return unknown;
    final val = value.toLowerCase();
    if (val.contains('خفيف') || val == 'low') return low;
    if (val.contains('متوسط') || val == 'medium') return medium;
    if (val.contains('عال') || val.contains('خطير') || val == 'high') {
      return high;
    }
    if (val.contains('حرج') || val.contains('بالغ') || val == 'critical') {
      return critical;
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
      case critical:
        return 'إصابة حرجة 🚨';
      case unknown:
        return 'غير محددة';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
// Service — Gemini أولاً للصور، Groq احتياطي
// ─────────────────────────────────────────────────────────────────────────────

class PlantDiagnosisService {
  bool _isInitialized = false;
  String? _systemPrompt;
  bool _isGroq = false;

  // Gemini
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const List<String> _geminiModels = [
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  // Groq احتياطي
  static const String _groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const List<String> _groqVisionModels = [
    'meta-llama/llama-4-scout-17b-16e-instruct',
    'meta-llama/llama-4-maverick-17b-128e-instruct',
  ];

  // xAI احتياطي
  static const String _xaiBaseUrl = 'https://api.x.ai/v1/chat/completions';
  static const List<String> _xaiVisionModels = [
    'grok-2-vision-1212',
    'grok-2-vision',
  ];

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  PlantDiagnosisService();

  // ── المفاتيح ──
  String get _geminiKey => (dotenv.env['GEMINI_API_KEY'] ?? '').trim();

  String get _groqOrXaiKey =>
      (dotenv.env['zarea'] ??
              dotenv.env['smart_farmar2'] ??
              dotenv.env['GROK_API_KEY'] ??
              dotenv.env['XAI_API_KEY'] ??
              '')
          .trim();

  static const String _defaultPrompt = '''
أنت "المهندس زرعة"، خبير زراعي متخصص في تشخيص أمراض النباتات.
حلل الصورة المرسلة وأرجع النتيجة بتنسيق JSON فقط بدون أي نص إضافي.

الهيكل المطلوب بالضبط:
{
  "plantName": "اسم النبتة بالعربية (والعلمي)",
  "isHealthy": true أو false,
  "diseaseType": "اسم المرض أو سليمة",
  "severityLevel": "Low | Medium | High | Critical",
  "diseaseCauses": "أسباب الإصابة",
  "treatmentMethods": "خطوات العلاج: 1... 2...",
  "preventionTips": ["نصيحة 1", "نصيحة 2", "نصيحة 3"]
}

قواعد:
- إذا كان النبات سليماً: isHealthy = true, severityLevel = "Low"
- إذا لم تتعرف على النبات: plantName = "نبات غير محدد"
- لا تضف أي نص قبل أو بعد JSON
- preventionTips مصفوفة نصوص دائماً
''';

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final key = _groqOrXaiKey;
    _isGroq = key.startsWith('gsk_') || key.contains('gsk');

    try {
      final data = await rootBundle.loadString(
        'assets/ai/diagnosis_prompt.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(data);
      _systemPrompt = jsonData['system_instruction'] as String?;
      debugPrint('PlantDiagnosisService: Prompt loaded ✅');
    } catch (e) {
      debugPrint('PlantDiagnosisService: Using fallback prompt. $e');
      _systemPrompt = _defaultPrompt;
    }

    debugPrint(
      'PlantDiagnosisService: Ready'
      ' | Gemini: ${_geminiKey.isNotEmpty ? "✅" : "❌"}'
      ' | Groq/xAI: ${_groqOrXaiKey.isNotEmpty ? "✅" : "❌"}',
    );
  }

  // ── ضغط الصورة ──
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final srcPath = '${tempDir.path}/src_$ts.jpg';
      final targetPath = '${tempDir.path}/diag_$ts.jpg';

      await File(srcPath).writeAsBytes(imageBytes);
      final result = await FlutterImageCompress.compressAndGetFile(
        srcPath,
        targetPath,
        minWidth: 800,
        minHeight: 800,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      try {
        await File(srcPath).delete();
      } catch (_) {}
      if (result == null) return imageBytes;

      final compressed = await result.readAsBytes();
      try {
        await File(targetPath).delete();
      } catch (_) {}

      debugPrint(
        'PlantDiagnosisService: ${imageBytes.length} → ${compressed.length} bytes',
      );
      return compressed;
    } catch (e) {
      debugPrint('PlantDiagnosisService: Compress error: $e');
      return imageBytes;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // التشخيص الرئيسي
  // ─────────────────────────────────────────────────────────────────────────

  Future<PlantDiagnosisResult> diagnose(Uint8List imageBytes) async {
    await _ensureInitialized();

    final compressed = await _compressImage(imageBytes);
    final base64Image = base64Encode(compressed);
    final prompt = _systemPrompt ?? _defaultPrompt;

    // 1️⃣ جرب Gemini أولاً
    if (_geminiKey.isNotEmpty) {
      final result = await _diagnoseWithGemini(base64Image, prompt);
      if (result != null) return result;
      debugPrint('PlantDiagnosisService: Gemini failed → falling back');
    } else {
      debugPrint('PlantDiagnosisService: No Gemini key → skipping');
    }

    // 2️⃣ احتياطي: Groq أو xAI
    if (_groqOrXaiKey.isNotEmpty) {
      final result = await _diagnoseWithOpenAIFormat(base64Image, prompt);
      if (result != null) return result;
    }

    return PlantDiagnosisResult.fromError(
      'تعذر الحصول على تشخيص. يرجى المحاولة مرة أخرى.',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Gemini Vision
  // ─────────────────────────────────────────────────────────────────────────

  Future<PlantDiagnosisResult?> _diagnoseWithGemini(
    String base64Image,
    String prompt,
  ) async {
    // ✅ إضافة تعليمات JSON صريحة في نهاية الـ prompt
    final enhancedPrompt =
        '$prompt\n\nمهم جداً: ابدأ ردك مباشرة بـ { وأنهه بـ }';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': enhancedPrompt},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 1024,
        // ✅ حذفنا responseMimeType لأنه يسبب مشاكل مع بعض النماذج
      },
    };

    for (final model in _geminiModels) {
      try {
        debugPrint('PlantDiagnosisService: Gemini → $model');

        final url = '$_geminiBaseUrl/$model:generateContent?key=$_geminiKey';
        final response = await _dio.post<Map<String, dynamic>>(
          url,
          data: requestBody,
        );

        if (response.statusCode == 200 && response.data != null) {
          // ✅ التحقق من وجود محتوى قبل المعالجة
          final candidates = response.data!['candidates'] as List?;
          if (candidates == null || candidates.isEmpty) {
            debugPrint('PlantDiagnosisService: Gemini no candidates → $model');
            continue;
          }

          // ✅ التحقق من finishReason
          final finishReason = candidates[0]['finishReason'] as String?;
          if (finishReason == 'SAFETY' || finishReason == 'RECITATION') {
            debugPrint(
              'PlantDiagnosisService: Gemini blocked ($finishReason) → trying next',
            );
            continue;
          }

          final rawText =
              candidates[0]['content']?['parts']?[0]?['text'] as String?;
          debugPrint('PlantDiagnosisService: Gemini raw ↩ $rawText');

          if (rawText == null || rawText.trim().isEmpty) {
            debugPrint('PlantDiagnosisService: Gemini empty → $model');
            continue;
          }

          final result = _parseResponse(rawText);
          // ✅ التحقق من أن النتيجة ليست خطأ قبل إرجاعها
          if (result.plantName != 'تعذر التحديد') return result;

          debugPrint(
            'PlantDiagnosisService: Gemini parse failed → trying next model',
          );
          continue;
        }
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final errorBody = e.response?.data?.toString() ?? e.message ?? '';
        debugPrint(
          'PlantDiagnosisService: Gemini error ($model) [$status]: $errorBody',
        );

        if (status == 429 && model != _geminiModels.last) {
          await Future.delayed(
            const Duration(seconds: 2),
          ); // انتظر قبل المحاولة التالية
          continue;
        }
        if (status == 400) continue;
        if (model == _geminiModels.last) return null;
      } catch (e) {
        debugPrint('PlantDiagnosisService: Gemini unexpected ($model): $e');
        if (model == _geminiModels.last) return null;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Groq / xAI — OpenAI format احتياطي
  // ─────────────────────────────────────────────────────────────────────────

  Future<PlantDiagnosisResult?> _diagnoseWithOpenAIFormat(
    String base64Image,
    String prompt,
  ) async {
    final String baseUrl;
    final List<String> models;

    if (_isGroq) {
      baseUrl = _groqBaseUrl;
      models = _groqVisionModels;
      debugPrint('PlantDiagnosisService: Fallback → Groq Vision');
    } else {
      baseUrl = _xaiBaseUrl;
      models = _xaiVisionModels;
      debugPrint('PlantDiagnosisService: Fallback → xAI Vision');
    }

    final messages = [
      {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': prompt},
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image',
              'detail': 'high',
            },
          },
        ],
      },
    ];

    for (final model in models) {
      try {
        debugPrint('PlantDiagnosisService: OpenAI-format → $model');

        final Map<String, dynamic> body = {
          'model': model,
          'messages': messages,
          'temperature': 0.1,
          'max_tokens': 1024,
        };

        // response_format مدعوم فقط في xAI وليس Groq Vision
        if (!_isGroq) {
          body['response_format'] = {'type': 'json_object'};
        }

        final response = await _dio.post<Map<String, dynamic>>(
          baseUrl,
          data: body,
          options: Options(headers: {'Authorization': 'Bearer $_groqOrXaiKey'}),
        );

        if (response.statusCode == 200 && response.data != null) {
          final rawText =
              response.data!['choices']?[0]?['message']?['content'] as String?;

          debugPrint('PlantDiagnosisService: OpenAI-format raw ↩ $rawText');

          if (rawText == null || rawText.trim().isEmpty) continue;
          return _parseResponse(rawText);
        }
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final errorBody = e.response?.data?.toString() ?? e.message ?? '';
        debugPrint(
          'PlantDiagnosisService: OpenAI-format error ($model) [$status]: $errorBody',
        );

        if (status == 429) {
          return PlantDiagnosisResult.fromError(
            'تم تجاوز حد الطلبات. يرجى المحاولة بعد قليل.',
          );
        }
        if (status == 400 || status == 404) continue;
        if (model == models.last) return null;
      } catch (e) {
        debugPrint(
          'PlantDiagnosisService: OpenAI-format unexpected ($model): $e',
        );
        if (model == models.last) return null;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // تحليل الرد
  // ─────────────────────────────────────────────────────────────────────────

  PlantDiagnosisResult _parseResponse(String rawText) {
    try {
      String cleanJson = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final start = cleanJson.indexOf('{');
      final end = cleanJson.lastIndexOf('}');

      if (start == -1) {
        debugPrint('PlantDiagnosisService: No JSON found');
        return PlantDiagnosisResult.fromError(
          'تنسيق الرد غير صالح. يرجى المحاولة مرة أخرى.',
        );
      }

      String jsonStr;
      if (end == -1 || end <= start) {
        jsonStr = _repairTruncatedJson(cleanJson.substring(start));
        debugPrint('PlantDiagnosisService: Repaired truncated JSON');
      } else {
        jsonStr = cleanJson.substring(start, end + 1);
      }

      debugPrint('PlantDiagnosisService: Parsing → $jsonStr');
      final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
      return PlantDiagnosisResult.fromJson(jsonData, rawText);
    } catch (e) {
      debugPrint('PlantDiagnosisService: Parse error: $e');
      return PlantDiagnosisResult.fromError(
        'فشل في تحليل البيانات. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  String _repairTruncatedJson(String json) {
    final lastComma = json.lastIndexOf(',');
    final lastColon = json.lastIndexOf(':');
    final cutPoint = lastComma > lastColon ? lastComma : lastColon;

    String trimmed = json;
    if (cutPoint > 0) {
      if (lastColon > lastComma) {
        final keyStart = json.lastIndexOf('"', lastColon - 1);
        if (keyStart > 0) {
          final beforeKey = json.lastIndexOf(',', keyStart);
          trimmed = json.substring(0, beforeKey > 0 ? beforeKey : keyStart);
        } else {
          trimmed = json.substring(0, lastColon);
        }
      } else {
        trimmed = json.substring(0, lastComma);
      }
    }

    int openBraces = 0;
    int openBrackets = 0;
    bool inString = false;
    for (int i = 0; i < trimmed.length; i++) {
      final c = trimmed[i];
      if (c == '"' && (i == 0 || trimmed[i - 1] != '\\')) {
        inString = !inString;
      } else if (!inString) {
        if (c == '{') openBraces++;
        if (c == '}') openBraces--;
        if (c == '[') openBrackets++;
        if (c == ']') openBrackets--;
      }
    }

    final buffer = StringBuffer(trimmed);
    for (int i = 0; i < openBrackets; i++) {
      buffer.write(']');
    }
    for (int i = 0; i < openBraces; i++) {
      buffer.write('}');
    }
    return buffer.toString();
  }
}
