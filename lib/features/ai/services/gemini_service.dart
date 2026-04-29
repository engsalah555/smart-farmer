import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  String? _initError;
  String? _systemInstruction;
  bool _isInitialized = false;

  // gemini-2.0-flash-lite: 30 RPM مجاني (ضعف gemini-2.0-flash)
  static const String _primaryModel = 'gemini-2.0-flash-lite';
  static const String _fallbackModel = 'gemini-2.0-flash';

  String _activeModel = _primaryModel;

  static String _buildUrl(String model) =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

  GeminiService();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _initError = 'مفتاح Gemini AI غير موجود في ملف .env';
      return;
    }

    try {
      final promptData =
          await rootBundle.loadString('assets/ai/chatbot_prompt.json');
      final Map<String, dynamic> promptJson = jsonDecode(promptData);
      _systemInstruction = promptJson['system_instruction'] ?? '';
    } catch (e) {
      _systemInstruction = 'أنت مساعد زراعي ذكي لتطبيق مزرعتي.';
    }

    debugPrint('GeminiService: initialized with model $_activeModel');
  }

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// إرسال رسالة واستقبال الرد — مع إعادة المحاولة تلقائياً
  Stream<String> sendMessageStream(
    String message, {
    List<int>? imageBytes,
    bool useHistory = false,
  }) async* {
    await _ensureInitialized();
    if (_initError != null) {
      yield _initError!;
      return;
    }

    // بناء الـ parts في isolate منفصل لتجنب تعطل الخيط الرئيسي
    final parts = <Map<String, dynamic>>[
      {'text': message},
    ];

    if (imageBytes != null) {
      final encoded = await compute(_encodeBase64, imageBytes);
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': encoded,
        }
      });
    }

    final bodyMap = {
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction ?? ''}
        ]
      },
      'contents': [
        {'role': 'user', 'parts': parts}
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    };

    // محاولة أولى بالموديل الرئيسي، ثم الاحتياطي عند 429
    for (final model in [_primaryModel, _fallbackModel]) {
      try {
        final body = await compute(_encodeJson, bodyMap);
        final uri = Uri.parse('${_buildUrl(model)}?key=$_apiKey');

        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          _activeModel = model;
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final text =
              data['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (text != null) yield text.toString();
          return;
        } else if (response.statusCode == 429) {
          debugPrint('GeminiService: quota exceeded for $model, trying next...');
          if (model == _fallbackModel) {
            yield '⚠️ الحد اليومي المجاني تجاوز. يرجى المحاولة بعد دقيقة أو استخدام مفتاح API آخر.';
          }
          continue; // جرب الموديل الاحتياطي
        } else {
          debugPrint('GeminiService error ${response.statusCode}: ${response.body}');
          yield _getFriendlyError(response.statusCode, response.body);
          return;
        }
      } catch (e) {
        debugPrint('GeminiService exception ($model): $e');
        if (model == _fallbackModel) {
          yield _getFriendlyError(null, e.toString());
        }
      }
    }
  }

  /// إرسال رسالة واستقبال الرد مرة واحدة
  Future<String> sendMessage(String message, {bool useHistory = false}) async {
    String result = '';
    await for (final chunk in sendMessageStream(message)) {
      result += chunk;
    }
    return result.isEmpty ? 'لم أتمكن من فهم طلبك.' : result;
  }

  String _getFriendlyError(int? statusCode, String body) {
    if (statusCode == 403 || body.contains('API_KEY') || body.contains('403')) {
      return 'المفتاح المستخدم غير صالح. يرجى التحقق من الإعدادات.';
    } else if (statusCode == 429 ||
        body.contains('quota') ||
        body.contains('RESOURCE_EXHAUSTED')) {
      return '⚠️ تم تجاوز الحد المجاني مؤقتاً. يرجى المحاولة بعد دقيقة.';
    } else if (body.contains('SocketException') ||
        body.contains('TimeoutException')) {
      return 'تأكد من اتصالك بالإنترنت.';
    }
    return 'حدث خطأ في الاتصال بالمساعد الذكي.';
  }

  void resetChat() {
    debugPrint('GeminiService: chat reset');
  }
}

// دوال تعمل في isolate منفصل لتجنب تجميد الواجهة
String _encodeBase64(List<int> bytes) => base64Encode(bytes);
String _encodeJson(Map<String, dynamic> data) => jsonEncode(data);
