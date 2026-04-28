import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  String? _initError;
  final String _currentModelName = 'gemini-1.5-flash';

  GeminiService() {
    // Initializing lazily
  }

  Future<void> _ensureInitialized() async {
    if (_model != null) return;
    await _initModel();
  }

  Future<void> _initModel() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        _initError = 'مفتاح Gemini AI غير موجود في ملف .env';
        return;
      }

      final promptData = await rootBundle.loadString('assets/ai/chatbot_prompt.json');
      final Map<String, dynamic> promptJson = jsonDecode(promptData);
      final systemInstructionText = promptJson['system_instruction'];

      _model = GenerativeModel(
        model: _currentModelName,
        apiKey: apiKey,
        systemInstruction: Content.system(systemInstructionText),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1024,
          responseMimeType: 'application/json',
        ),
      );
      _chatSession = _model!.startChat();
      _initError = null;
      debugPrint('GeminiService: initialized with model $_currentModelName');
    } catch (e) {
      debugPrint('GeminiService init error: $e');
      _initError = 'حدث خطأ أثناء إعداد المساعد الذكي.';
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
    await _ensureInitialized();
    if (_initError != null || _chatSession == null) {
      yield _initError ??
          'المساعد الذكي غير متوفر حالياً. تحقق من مفتاح GEMINI_API_KEY في ملف .env';
      return;
    }

    try {
      final parts = <Part>[TextPart(message)];
      if (imageBytes != null) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }

      final responseStream = _chatSession!.sendMessageStream(
        Content.multi(parts),
      );

      String accumulatedBody = '';
      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          accumulatedBody += chunk.text!;
          
          // محاولة استخراج الحقل "text" من الـ JSON المتراكم لعرضه أثناء الكتابة
          final match = RegExp(r'"text":\s*"([^"]*)').firstMatch(accumulatedBody);
          if (match != null && match.group(1) != null) {
            yield _unescapeJsonString(match.group(1)!);
          }
        }
      }
    } catch (e) {
      debugPrint('GeminiService stream error: $e');
      final errorStr = e.toString();

      if (errorStr.contains('API_KEY') || errorStr.contains('403')) {
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
    await _ensureInitialized();
    if (_initError != null || _chatSession == null) {
      return _initError ?? 'المساعد الذكي غير متوفر حالياً.';
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      final rawText = response.text ?? '';
      if (rawText.isEmpty) return 'لم أتمكن من فهم طلبك.';
      
      try {
        final Map<String, dynamic> data = jsonDecode(rawText);
        return data['text'] ?? 'لم أتمكن من استخراج النص.';
      } catch (e) {
        return rawText; // fallback to raw text if json fails
      }
    } catch (e) {
      debugPrint('GeminiService sendMessage error: $e');
      return 'حدث خطأ في الاتصال بالمساعد الذكي. يرجى المحاولة لاحقاً.';
    }
  }

  String _unescapeJsonString(String input) {
    return input
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\');
  }
}
