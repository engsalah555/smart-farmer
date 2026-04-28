import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// نموذج بيانات نتيجة تشخيص المرض
class PlantDiagnosisResult {
  final String plantName;        // اسم النبتة
  final String diseaseType;      // نوع المرض
  final String diseaseCauses;    // أسباب المرض
  final String treatmentMethods; // طرق العلاج
  final String severityLevel;    // مستوى خطورة الإصابة
  final String preventionTips;   // نصائح الوقاية
  final bool isHealthy;          // هل النبتة سليمة؟
  final String rawResponse;      // الاستجابة الخام

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

/// خدمة تشخيص أمراض النباتات باستخدام Gemini Vision AI
class PlantDiagnosisService {
  GenerativeModel? _model;
  final String _currentModel = 'gemini-1.5-flash';
  bool _isInitialized = false;
  String? _systemPrompt;

  PlantDiagnosisService() {
    // Initializing lazily or via explicit call
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      final promptData = await rootBundle.loadString('assets/ai/diagnosis_prompt.json');
      final Map<String, dynamic> promptJson = jsonDecode(promptData);
      _systemPrompt = promptJson['system_instruction'];

      final apiKey = _getApiKey();
      if (apiKey.isEmpty) {
        debugPrint('PlantDiagnosisService: No API key found');
        return;
      }

      _model = _createModel(apiKey, _currentModel);
      _isInitialized = _model != null;
    } catch (e) {
      debugPrint('PlantDiagnosisService initialization error: $e');
    }
  }

  String _getApiKey() {
    return dotenv.env['PLANT_DIAGNOSIS_API_KEY'] ?? '';
  }

  GenerativeModel? _createModel(String apiKey, String modelName) {
    if (_systemPrompt == null) return null;
    
    try {
      return GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(_systemPrompt!),
        generationConfig: GenerationConfig(
          temperature: 0.1, // Lower temperature for more consistent JSON
          maxOutputTokens: 2048,
          responseMimeType: 'application/json',
        ),
      );
    } catch (e) {
      debugPrint('PlantDiagnosisService _createModel error: $e');
      return null;
    }
  }

  bool get isReady => _isInitialized && _model != null;

  /// تحليل صورة النبتة وإرجاع نتيجة التشخيص المنظمة
  Future<PlantDiagnosisResult> diagnose(Uint8List imageBytes) async {
    await _ensureInitialized();
    
    if (!isReady) {
      return PlantDiagnosisResult.fromError('خدمة التشخيص غير متاحة حالياً.');
    }

    try {
      final response = await _model!.generateContent([
        Content.multi([
          TextPart('حلل هذه الصورة وأعطني النتائج بتنسيق JSON.'),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      final rawText = response.text ?? '';
      if (rawText.isEmpty) {
        return PlantDiagnosisResult.fromError('لم يتم تلقي استجابة من النظام.');
      }

      try {
        final Map<String, dynamic> jsonData = jsonDecode(rawText);
        return PlantDiagnosisResult.fromJson(jsonData, rawText);
      } catch (parseError) {
        debugPrint('JSON Parse Error: $parseError\nRaw text: $rawText');
        return PlantDiagnosisResult.fromError('فشل في تحليل بيانات الاستجابة.');
      }

    } catch (e) {
      return await _handleDiagnoseError(e, imageBytes);
    }
  }

  Future<PlantDiagnosisResult> _handleDiagnoseError(Object e, Uint8List imageBytes) async {
    final errorStr = e.toString().toUpperCase();
    debugPrint('PlantDiagnosisService Error: $e');

    if (errorStr.contains('QUOTA') || errorStr.contains('RESOURCE_EXHAUSTED')) {
      return PlantDiagnosisResult.fromError('تم تجاوز الحد المسموح به. يرجى المحاولة لاحقاً.');
    }

    if (errorStr.contains('SOCKETEXCEPTION') || errorStr.contains('NETWORK')) {
      return PlantDiagnosisResult.fromError('فشل الاتصال بالإنترنت.');
    }

    return PlantDiagnosisResult.fromError('حدث خطأ غير متوقع أثناء التشخيص.');
  }

}
