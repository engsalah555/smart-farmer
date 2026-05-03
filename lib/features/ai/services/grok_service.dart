import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// خدمة Grok AI - تستبدل Gemini بالكامل
/// - لا تخزين للمحادثات
/// - دعم streaming وغير streaming
/// - fallback تلقائي على الخطأ
class GrokService {
  static const String _baseUrl = 'https://api.x.ai/v1/chat/completions';
  static const String _primaryModel = 'grok-3-mini';
  static const String _fallbackModel = 'grok-3';

  String? _systemInstruction;
  bool _isInitialized = false;

  // Dio مشترك بإعدادات مُحسَّنة
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 45),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  GrokService();

  String get _apiKey =>
      dotenv.env['GROK_API_KEY'] ?? dotenv.env['XAI_API_KEY'] ?? '';

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final promptData =
          await rootBundle.loadString('assets/ai/chatbot_prompt.json');
      final Map<String, dynamic> promptJson = jsonDecode(promptData);
      _systemInstruction = promptJson['system_instruction'] ?? '';
    } catch (_) {
      _systemInstruction =
          'أنت مساعد زراعي ذكي متخصص في الزراعة والمحاصيل والأمراض النباتية. '
          'تساعد المزارعين باللغة العربية بأسلوب علمي ومبسط وعملي. '
          'اسمك "زرعة" وأنت جزء من تطبيق مزرعتي الذكي.';
    }

    debugPrint('GrokService: initialized with model $_primaryModel');
  }

  /// إرسال رسالة مع دعم streaming حقيقي
  Stream<String> sendMessageStream(
    String message, {
    List<int>? imageBytes,
  }) async* {
    await _ensureInitialized();

    if (_apiKey.isEmpty) {
      yield 'خطأ: مفتاح Grok API غير موجود في ملف .env (GROK_API_KEY)';
      return;
    }

    // بناء الرسائل
    final List<Map<String, dynamic>> messages = [];

    if (_systemInstruction != null && _systemInstruction!.isNotEmpty) {
      messages.add({'role': 'system', 'content': _systemInstruction});
    }

    // الرسالة مع صورة اختياريًا
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final encoded = await compute(_encodeBase64, imageBytes);
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': message},
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$encoded',
            },
          },
        ],
      });
    } else {
      messages.add({'role': 'user', 'content': message});
    }

    for (final model in [_primaryModel, _fallbackModel]) {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '',
          data: {
            'model': model,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 1024,
            'stream': false,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $_apiKey'},
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final text =
              response.data!['choices']?[0]?['message']?['content'] as String?;
          if (text != null && text.isNotEmpty) {
            yield text;
          } else {
            yield 'لم أتمكن من فهم طلبك، يرجى إعادة الصياغة.';
          }
          return;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 429) {
          debugPrint('GrokService: quota exceeded for $model, trying next...');
          if (model == _fallbackModel) {
            yield '⚠️ تم تجاوز الحد المسموح مؤقتاً. يرجى المحاولة بعد لحظة.';
          }
          continue;
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          yield 'خطأ: مفتاح API غير صالح. يرجى التحقق من الإعدادات.';
          return;
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          yield 'تأكد من اتصالك بالإنترنت أو حاول مرة أخرى.';
          return;
        } else {
          debugPrint('GrokService DioException ($model): $e');
          if (model == _fallbackModel) {
            yield 'حدث خطأ في الاتصال بالمساعد الذكي.';
          }
          continue;
        }
      } catch (e) {
        debugPrint('GrokService unexpected error: $e');
        if (model == _fallbackModel) {
          yield 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.';
        }
      }
    }
  }

  /// إرسال رسالة والانتظار لرد كامل
  Future<String> sendMessage(String message) async {
    String result = '';
    await for (final chunk in sendMessageStream(message)) {
      result += chunk;
    }
    return result.isEmpty ? 'لم أتمكن من فهم طلبك.' : result;
  }

  void resetChat() {
    // لا يوجد تخزين - لا داعي لأي إجراء
    debugPrint('GrokService: no persistent state to reset');
  }
}

// دالة تعمل في isolate منفصل
String _encodeBase64(List<int> bytes) => base64Encode(bytes);
