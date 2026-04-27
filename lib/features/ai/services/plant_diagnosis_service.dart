import 'package:flutter/foundation.dart';
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
}

/// خدمة تشخيص أمراض النباتات باستخدام Gemini Vision AI
class PlantDiagnosisService {
  GenerativeModel? _model;
  final String _currentModel = 'gemini-1.5-flash';
  bool _isInitialized = false;

  static const String _systemPrompt =
      'أنت طبيب نباتات متخصص وخبير زراعي دقيق للغاية. '
      'عند تحليل صورة نبات، يجب أن تُقدّم تقريراً طبياً زراعياً دقيقاً ومنظماً. '
      'التزم دائماً بإخراج ردودك بالصيغة التالية حرفياً، مع ملء كل قسم بمعلومات دقيقة ومفيدة:\n\n'
      'اسم النبتة: [اكتب هنا الاسم العلمي والشائع للنبتة]\n'
      'نوع المرض: [اكتب هنا اسم المرض أو الآفة بدقة، أو "النبتة سليمة وصحية" إذا لم توجد إصابة]\n'
      'مستوى الخطورة: [اكتب واحدة فقط: خطيرة جداً / عالية / متوسطة / منخفضة / لا توجد إصابة]\n'
      'أسباب المرض: [اشرح هنا بالتفصيل الأسباب العلمية للمرض، كالفطريات أو البكتيريا أو العوامل البيئية]\n'
      'طرق العلاج: [قدّم هنا خطة علاجية واضحة ومرتبة خطوة بخطوة، تشمل المبيدات المناسبة والممارسات الزراعية]\n'
      'نصائح الوقاية: [اذكر هنا 3 إلى 5 نصائح وقائية لمنع تكرار الإصابة]\n\n'
      'قواعد مهمة:\n'
      '- أجب دائماً باللغة العربية الفصحى السهلة.\n'
      '- كن دقيقاً وعلمياً في التشخيص.\n'
      '- إذا كانت الصورة غير واضحة أو لا تحتوي على نبتة، أخبر المستخدم بذلك بوضوح.\n'
      '- لا تذكر معلومات عامة بدون تطبيقها على الصورة المحددة.\n'
      '- حافظ على ترتيب الأقسام كما هو محدد تماماً.';

  PlantDiagnosisService() {
    _init();
  }

  void _init() {
    final apiKey = _getApiKey();
    if (apiKey.isEmpty) {
      debugPrint('PlantDiagnosisService: No API key found');
      return;
    }

    _model = _createModel(apiKey, _currentModel);
    _isInitialized = _model != null;
    
    if (_isInitialized) {
      debugPrint('PlantDiagnosisService: initialized with model $_currentModel');
    }
  }

  String _getApiKey() {
    return (dotenv.env['PLANT_DIAGNOSIS_API_KEY'] ?? '').isNotEmpty
        ? dotenv.env['PLANT_DIAGNOSIS_API_KEY']!
        : dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  GenerativeModel? _createModel(String apiKey, String modelName) {
    try {
      return GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 2048,
          topP: 0.8,
          topK: 40,
        ),
      );
    } catch (e) {
      debugPrint('PlantDiagnosisService _createModel error: $e');
      return null;
    }
  }

  bool get isReady => _isInitialized && _model != null;

  /// تبديل المفتاح (للـ fallback عند انتهاء الحصة)
  void _switchToKey(String apiKey) {
    _model = _createModel(apiKey, _currentModel);
    _isInitialized = _model != null;
  }

  /// تحليل صورة النبتة وإرجاع نتيجة التشخيص المنظمة
  Future<PlantDiagnosisResult> diagnose(Uint8List imageBytes) async {
    if (!isReady) {
      return _errorResult('خدمة التشخيص غير متاحة. تأكد من إعداد API Keys بشكل صحيح.');
    }

    try {
      final response = await _model!.generateContent([
        Content.multi([
          TextPart('حلل هذه الصورة بدقة وفق التنسيق المطلوب.'),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      final rawText = response.text ?? '';
      return rawText.isNotEmpty 
          ? _parseResponse(rawText) 
          : _errorResult('لم يتم تلقي استجابة من النظام.');

    } catch (e) {
      return await _handleDiagnoseError(e, imageBytes);
    }
  }

  Future<PlantDiagnosisResult> _handleDiagnoseError(Object e, Uint8List imageBytes) async {
    final errorStr = e.toString().toUpperCase();
    debugPrint('PlantDiagnosisService Error: $e');

    // 1. معالجة أخطاء الحصة (Quota / Resource Exhausted)
    if (errorStr.contains('QUOTA') || errorStr.contains('RESOURCE_EXHAUSTED')) {
      final fallbackKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (fallbackKey.isNotEmpty && _getApiKey() != fallbackKey) {
        _switchToKey(fallbackKey);
        return diagnose(imageBytes);
      }
      return _errorResult('تم تجاوز الحد المسموح به (Quota). يرجى المحاولة لاحقاً.');
    }

    // 2. أخطاء الشبكة
    if (errorStr.contains('SOCKETEXCEPTION') || errorStr.contains('NETWORK')) {
      return _errorResult('فشل الاتصال بالإنترنت. يرجى التحقق من الشبكة.');
    }

    return _errorResult('حدث خطأ غير متوقع أثناء التشخيص.');
  }

  /// تحليل نص الاستجابة واستخراج الأقسام
  PlantDiagnosisResult _parseResponse(String rawText) {
    String extract(String key, {String? endKey}) {
      final pattern = endKey != null 
          ? RegExp('$key:\\s*(.*?)(?=$endKey:|\\Z)', dotAll: true, caseSensitive: false)
          : RegExp('$key:\\s*(.*)', caseSensitive: false);
      
      final match = pattern.firstMatch(rawText);
      return match?.group(1)?.trim() ?? '';
    }

    final diseaseType = extract('نوع المرض', endKey: 'مستوى الخطورة');
    final severity    = extract('مستوى الخطورة', endKey: 'أسباب المرض');
    
    final isHealthy = _checkIfHealthy(diseaseType, severity);

    return PlantDiagnosisResult(
      plantName: extract('اسم النبتة', endKey: 'نوع المرض').isNotEmpty ? extract('اسم النبتة', endKey: 'نوع المرض') : 'نبتة غير محددة',
      diseaseType: diseaseType.isNotEmpty ? diseaseType : 'غير محدد',
      diseaseCauses: extract('أسباب المرض', endKey: 'طرق العلاج'),
      treatmentMethods: extract('طرق العلاج', endKey: 'نصائح الوقاية'),
      severityLevel: severity,
      preventionTips: extract('نصائح الوقاية'),
      isHealthy: isHealthy,
      rawResponse: rawText,
    );
  }

  bool _checkIfHealthy(String diseaseType, String severity) {
    final keywords = ['سليم', 'صحي', 'لا توجد إصابة', 'طبيعي'];
    return keywords.any((k) => diseaseType.contains(k)) || severity.contains('لا توجد');
  }

  PlantDiagnosisResult _errorResult(String message) {
    return PlantDiagnosisResult(
      plantName: 'غير معروف',
      diseaseType: 'تعذّر التشخيص',
      diseaseCauses: message,
      treatmentMethods: 'يرجى إعادة المحاولة بصورة أوضح وأكثر إضاءة.',
      severityLevel: 'غير محددة',
      preventionTips: '',
      isHealthy: false,
      rawResponse: message,
    );
  }
}
