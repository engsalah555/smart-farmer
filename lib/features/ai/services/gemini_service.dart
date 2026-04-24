import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  String? _initError;
  String _currentModelName = _modelFallbacks.first;

  // قائمة بالنماذج المتاحة بترتيب الأولوية
  static const List<String> _modelFallbacks = [
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash',
    'gemini-2.0-flash',
  ];

  GeminiService() {
    _initModel();
  }

  void _initModel({String? modelOverride}) {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        _initError = 'مفتاح Gemini AI غير موجود في ملف .env';
        return;
      }

      final modelName = modelOverride ?? _modelFallbacks.first;

      final systemInstruction = Content.system(
        'أنت استشاري زراعي ذكي ومساعد رسمي لتطبيق "مزرعتي الذكية".\n'
        'مهمتك الأساسية هي الإجابة عن كافة الأسئلة المتعلقة بالنباتات، الزراعة، المحاصيل، وكل ما يخص الشأن الزراعي، بالإضافة إلى تقديم الدعم والإجابة عن أي أسئلة حول استخدام التطبيق ومميزاته.\n\n'
        'تعليمات صارمة يجب الالتزام بها في كل رد:\n'
        '1. أجب دائماً باللغة العربية بأسلوب احترافي، ودود، وسهل الفهم للمزارع والمستخدم العادي.\n'
        '2. يمكنك تقديم معلومات موسوعة عن أي نبات أو محصول، فوائده، طرق زراعته، الري، التسميد، وحل مشاكل الآفات والأمراض الزراعية.\n'
        '3. إذا سأل المستخدم عن متجر أدوات زراعية أو مشاتل، أرشده لاستخدام "خريطة المتاجر" أو "المتجر" الموجودة داخل التطبيق.\n'
        '4. يمكنك الإجابة عن الاستفسارات التقنية البسيطة حول كيفية استخدام التطبيق ومميزاته وكيفية الوصول لأقسامه (مثل حاسبة الأسمدة، المنتدى، الفحص الذكي للآفات).\n'
        '5. الممنوعات (قيود صارمة): يُمنع منعاً باتاً الإجابة عن أي سؤال خارج عن موضوع الزراعة، النباتات، تطبيقنا، أو الطبيعة المرتبطة بهما. إذا سألك المستخدم عن السياسة، الدين، البرمجة والتكنولوجيا العامة، العلوم الأخرى، أو أي موضوع آخر، اعتذر بلطف وأخبره أنك مبرمج فقط ومختص حصراً بكونك "استشاري زراعي ومساعد للتطبيق ,وتشخيص الامراض" ولا تقدم إجابات خارج هذا النطاق.\n'
        '6. نسق إجابتك باستخدام النقاط البارزة (Bullet points) لتكون سهلة القراءة على شاشات الجوال.\n'
        '7. إذا كان المستخدم يلقي التحية (مثل السلام عليكم، كيف الحال) أو يطرح سؤالاً قصيراً للتعارف، رد باختصار شديد وبطريقة ودية عارضاً مساعدتك (مثال: "أهلاً بك! كيف يمكنني خدمتك اليوم؟") ولا تقدم خطاباً طويلاً.',
      );

      _model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: systemInstruction,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1024,
        ),
      );
      _chatSession = _model!.startChat();
      _initError = null; // clear any previous error
      _currentModelName = modelName;
      debugPrint('GeminiService: initialized with model $modelName');
    } catch (e) {
      debugPrint('GeminiService init error: $e');
      _initError = 'حدث خطأ أثناء إعداد المساعد الذكي.';
    }
  }

  /// محاولة استخدام نموذج بديل في حال فشل الأول
  Future<void> _tryFallbackModel(String failedModel) async {
    final currentIdx = _modelFallbacks.indexOf(failedModel);
    if (currentIdx != -1 && currentIdx < _modelFallbacks.length - 1) {
      final nextModel = _modelFallbacks[currentIdx + 1];
      debugPrint('GeminiService: Falling back to $nextModel');
      _initModel(modelOverride: nextModel);
    }
  }

  /// إعادة تعيين المحادثة أو بدء محادثة مع سجل سابق
  void resetChat({List<Content>? history}) {
    if (_model != null) {
      _chatSession = _model!.startChat(history: history);
    }
  }

  /// الحصول على اسم النموذج الحالي
  String get currentModel => _currentModelName;

  /// التحقق من حالة الخدمة
  bool get isReady =>
      _model != null && _chatSession != null && _initError == null;

  /// إرسال رسالة واستقبال الرد كنص مستمر (Stream)
  Stream<String> sendMessageStream(
    String message, {
    Uint8List? imageBytes,
  }) async* {
    if (_initError != null || _chatSession == null) {
      yield _initError ??
          'المساعد الذكي غير متوفر حالياً. تحقق من مفتاح GEMINI_API_KEY في ملف .env';
      return;
    }

    String currentModelRef = _currentModelName;

    try {
      final parts = <Part>[TextPart(message)];
      if (imageBytes != null) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }

      final responseStream = _chatSession!.sendMessageStream(
        Content.multi(parts),
      );

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      debugPrint('GeminiService stream error: $e');
      final errorStr = e.toString();

      // محاولة نموذج بديل إذا كانت المشكلة في الموديل
      if (errorStr.contains('404') ||
          errorStr.contains('not found') ||
          errorStr.contains('MODEL_NOT_FOUND') ||
          errorStr.contains('deprecated') ||
          errorStr.contains('503') ||
          errorStr.contains('UNAVAILABLE') ||
          errorStr.contains('high demand')) {
        await _tryFallbackModel(currentModelRef);
        if (isReady) {
          yield 'جارٍ إعادة الاتصال بنموذج بديل، أرسل رسالتك مرة أخرى...';
        } else {
          yield 'لم يتمكن التطبيق من الاتصال بخدمة الذكاء الاصطناعي. يرجى التحقق من الاتصال بالإنترنت أو تحديث التطبيق.';
        }
      } else if (errorStr.contains('API_KEY') || errorStr.contains('403')) {
        yield 'المفتاح المستخدم لذكاء الاصطناعي غير صالح أو منتهي الصلاحية. يرجى التواصل مع الدعم.';
      } else if (errorStr.contains('quota') ||
          errorStr.contains('RESOURCE_EXHAUSTED')) {
        yield 'تم تجاوز الحد المسموح به مؤقتاً. يرجى الانتظار قليلاً ثم المحاولة مجدداً.';
      } else if (errorStr.contains('SocketException') ||
          errorStr.contains('network')) {
        yield 'تعذّر الاتصال بالإنترنت. تأكد من اتصالك بالشبكة وحاول مرة أخرى.';
      } else {
        yield 'حدث خطأ في الاتصال بالمساعد الذكي. يرجى المحاولة لاحقاً.';
      }
    }
  }

  /// إرسال رسالة واستقبال الرد مرة واحدة
  Future<String> sendMessage(String message) async {
    if (_initError != null || _chatSession == null) {
      return _initError ?? 'المساعد الذكي غير متوفر حالياً.';
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'لم أتمكن من فهم طلبك.';
    } catch (e) {
      debugPrint('GeminiService sendMessage error: $e');
      return 'حدث خطأ في الاتصال بالمساعد الذكي. يرجى المحاولة لاحقاً.';
    }
  }
}
