import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// خدمة AI ذكية - تدعم Grok (xAI) و Groq (LPU) مع دعم كامل للرؤية (Vision)
/// تكتشف تلقائياً نوع المفتاح وتستخدم الإعدادات المناسبة
class GrokService {
  String? _systemInstruction;
  bool _isInitialized = false;

  String _currentBaseUrl = 'https://api.x.ai/v1/chat/completions';
  String _currentPrimaryModel = 'grok-2-mini';
  String _currentFallbackModel = 'grok-2';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  GrokService();

  String get _apiKey {
    final key =
        (dotenv.env['zarea'] ??
                dotenv.env['smart_farmar2'] ??
                dotenv.env['GROK_API_KEY'] ??
                dotenv.env['XAI_API_KEY'] ??
                '')
            .trim();
    return key;
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final key = _apiKey;
    if (key.startsWith('gsk_') || key.contains('gsk')) {
      _currentBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
      _currentPrimaryModel = 'llama-3.1-8b-instant';
      _currentFallbackModel = 'llama-3.3-70b-versatile';
      debugPrint('GrokService: Identified Groq Provider');
    } else {
      _currentBaseUrl = 'https://api.x.ai/v1/chat/completions';
      _currentPrimaryModel = 'grok-2-1212';
      _currentFallbackModel = 'grok-2-mini';
      debugPrint('GrokService: Identified xAI Provider');
    }

    try {
      final promptData = await rootBundle.loadString(
        'assets/ai/chatbot_prompt.json',
      );
      final Map<String, dynamic> promptJson = jsonDecode(promptData);
      _systemInstruction = promptJson['system_instruction'];
    } catch (e) {
      debugPrint('GrokService: Error loading prompt, using default. $e');
      _systemInstruction =
          'أنت المهندس زرعة، مستشار زراعي خبير في تطبيق زرعة. ردودك صارمة، مختصرة، ومنظمة جداً. إذا سُئلت عن شيء غير زراعي أو خارج التطبيق، اعتذر بوضوح.';
    }

    debugPrint('GrokService: Ready (Model: $_currentPrimaryModel)');
  }

  Stream<String> sendMessageStream(
    String message, {
    List<int>? imageBytes,
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

    if (imageBytes != null && imageBytes.isNotEmpty) {
      Uint8List imageToSend = Uint8List.fromList(imageBytes);

      try {
        debugPrint('GrokService: جاري محاولة ضغط الصورة...');
        final result = await FlutterImageCompress.compressWithList(
          imageToSend,
          minWidth: 800,
          minHeight: 800,
          quality: 80,
        );

        if (result.isNotEmpty) {
          imageToSend = result;
          debugPrint('GrokService: تم ضغط الصورة بنجاح.');
        } else {
          debugPrint(
            'GrokService: عملية الضغط أرجعت بيانات فارغة، سيتم تخطي الضغط.',
          );
        }
      } catch (e) {
        debugPrint(
          'GrokService: فشل ضغط الصورة ($e). سيتم إرسال الصورة الأصلية كما هي.',
        );
      }

      final base64Image = await compute(_encodeBase64, imageToSend);

      final String safeMessage = message.trim().isNotEmpty
          ? message
          : 'يرجى تحليل هذه الصورة الزراعية وتقديم النصيحة المناسبة.';

      // ✅ التعديل الرئيسي: استخدام نماذج Llama 4 الداعمة للرؤية
      final List<String> visionModels = _apiKey.startsWith('gsk_')
          ? [
              'meta-llama/llama-4-scout-17b-16e-instruct',
              'meta-llama/llama-4-maverick-17b-128e-instruct',
            ]
          : ['grok-2-vision-1212', 'grok-2-vision'];

      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': safeMessage},
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image',
              'detail': 'high',
            },
          },
        ],
      });

      bool success = false;
      String lastError = '';

      for (final model in visionModels) {
        try {
          await for (final chunk in _makeRequest(
            _currentBaseUrl,
            model,
            messages,
          )) {
            if (chunk.startsWith('ERROR:')) {
              lastError = chunk.replaceFirst('ERROR:', '');
              if (lastError.contains('400') || lastError.contains('404')) break;

              if (model == visionModels.last) {
                yield 'عذراً، حدث خطأ فني أثناء تحليل الصورة.';
              }
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
          yield 'عذراً، خدمة تحليل الصور غير متاحة حالياً.';
        }
      }
    } else {
      messages.add({'role': 'user', 'content': message});

      bool success = false;
      String lastError = '';

      for (final model in [_currentPrimaryModel, _currentFallbackModel]) {
        try {
          await for (final chunk in _makeRequest(
            _currentBaseUrl,
            model,
            messages,
          )) {
            if (chunk.startsWith('ERROR:')) {
              lastError = chunk.replaceFirst('ERROR:', '');
              if (lastError.contains('400') || lastError.contains('404')) break;

              if (model == _currentFallbackModel) {
                yield 'عذراً، حدث خطأ فني.';
              }
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
  }

  Stream<String> _makeRequest(
    String url,
    String model,
    List<Map<String, dynamic>> messages,
  ) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        url,
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

      debugPrint('GrokService: API Error ($url): $errorBody');

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
      if (!chunk.contains('ERROR:')) {
        result += chunk;
      }
    }
    return result.isEmpty ? 'لم أتمكن من الحصول على رد.' : result;
  }

  void resetChat() {
    debugPrint('GrokService: Chat Reset');
  }
}

// دالة تعمل في isolate منفصل
String _encodeBase64(List<int> bytes) => base64Encode(bytes);
