import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// خدمة Chatbot — Groq للنص فقط
/// تحليل الصور يتولاه PlantDiagnosisService عبر Gemini
class GrokService {
  String? _systemInstruction;
  bool _isInitialized = false;

  static const String _groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _primaryModel = 'llama-3.1-8b-instant';
  static const String _fallbackModel = 'llama-3.3-70b-versatile';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  GrokService();

  String get _apiKey {
    return (dotenv.env['zarea'] ??
            dotenv.env['smart_farmar2'] ??
            dotenv.env['GROK_API_KEY'] ??
            dotenv.env['XAI_API_KEY'] ??
            '')
        .trim();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final promptData = await rootBundle.loadString(
        'assets/ai/chatbot_prompt.json',
      );
      final Map<String, dynamic> promptJson = jsonDecode(promptData);
      _systemInstruction = promptJson['system_instruction'];
    } catch (e) {
      debugPrint('GrokService: Error loading prompt, using default. $e');
      _systemInstruction =
          'أنت المهندس زرعة، مستشار زراعي خبير في تطبيق زرعة. '
          'ردودك صارمة، مختصرة، ومنظمة جداً. '
          'إذا سُئلت عن شيء غير زراعي أو خارج التطبيق، اعتذر بوضوح.';
    }

    debugPrint('GrokService: Ready (Model: $_primaryModel)');
  }

  Stream<String> sendMessageStream(
    String message, {
    List<Map<String, String>> chatHistory = const [],
  }) async* {
    await _ensureInitialized();

    if (_apiKey.isEmpty) {
      yield 'خطأ: مفتاح API غير موجود في إعدادات التطبيق.';
      return;
    }

    final List<Map<String, dynamic>> messages = [];

    if (_systemInstruction != null && _systemInstruction!.isNotEmpty) {
      messages.add({'role': 'system', 'content': _systemInstruction});
    }

    for (var msg in chatHistory) {
      messages.add({'role': msg['role'], 'content': msg['content']});
    }

    messages.add({'role': 'user', 'content': message});

    bool success = false;
    String lastError = '';

    for (final model in [_primaryModel, _fallbackModel]) {
      try {
        await for (final chunk in _makeRequest(model, messages)) {
          if (chunk.startsWith('ERROR:')) {
            lastError = chunk.replaceFirst('ERROR:', '');
            if (lastError.contains('400') || lastError.contains('404')) break;
            if (model == _fallbackModel) yield 'عذراً، حدث خطأ فني.';
            break;
          } else {
            yield chunk;
            success = true;
          }
        }
        if (success) return;
      } catch (e) {
        lastError = e.toString();
      }
    }

    if (!success) {
      if (lastError.contains('429')) {
        yield 'تم تجاوز حد الطلبات المسموح به حالياً. يرجى المحاولة بعد قليل.';
      } else {
        yield 'عذراً، الخدمة غير متاحة حالياً. تأكد من اتصالك بالإنترنت.';
      }
    }
  }

  Stream<String> _makeRequest(
    String model,
    List<Map<String, dynamic>> messages,
  ) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        _groqBaseUrl,
        data: {
          'model': model,
          'messages': messages,
          'temperature': 0.1,
          'stream': true,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $_apiKey'},
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final stream = response.data!.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (line.isEmpty) continue;
          if (line == 'data: [DONE]') break;
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;
            try {
              final Map<String, dynamic> decoded = jsonDecode(jsonStr);
              final chunk =
                  decoded['choices']?[0]?['delta']?['content'] as String?;
              if (chunk != null) yield chunk;
            } catch (_) {}
          }
        }
      } else {
        yield 'ERROR:فشل الطلب (${response.statusCode})';
      }
    } on DioException catch (e) {
      String errorBody = e.message ?? 'Unknown Error';
      if (e.response?.data is ResponseBody) {
        try {
          final stream = (e.response!.data as ResponseBody).stream;
          final bytes = await stream.expand((b) => b).toList();
          errorBody = utf8.decode(bytes);
        } catch (_) {}
      } else if (e.response?.data != null) {
        errorBody = e.response!.data.toString();
      }

      debugPrint('GrokService: API Error: $errorBody');

      if (e.response?.statusCode == 429) {
        yield 'ERROR:429';
      } else if (e.response?.statusCode == 400) {
        yield 'ERROR:400 - $errorBody';
      } else {
        yield 'ERROR:حدث خطأ في الاتصال';
      }
    } catch (e) {
      debugPrint('GrokService: Unexpected Error: $e');
      yield 'ERROR:حدث خطأ غير متوقع';
    }
  }

  Future<String> sendMessage(String message) async {
    String result = '';
    await for (final chunk in sendMessageStream(message)) {
      if (!chunk.contains('ERROR:')) result += chunk;
    }
    return result.isEmpty ? 'لم أتمكن من الحصول على رد.' : result;
  }

  void resetChat() => debugPrint('GrokService: Chat Reset');
}
