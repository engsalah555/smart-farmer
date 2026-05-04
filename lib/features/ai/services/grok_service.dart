import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// خدمة AI ذكية - تدعم Grok (xAI) و Groq (LPU)
/// تكتشف تلقائياً نوع المفتاح وتستخدم الإعدادات المناسبة
class GrokService {
  String? _systemInstruction;
  bool _isInitialized = false;

  // الإعدادات الافتراضية (سيتم تحديثها بناءً على المفتاح)
  String _currentBaseUrl = 'https://api.x.ai/v1/chat/completions';
  String _currentPrimaryModel = 'grok-2-mini';
  String _currentFallbackModel = 'grok-2';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  GrokService();

  String get _apiKey {
    // الأولوية للمفتاح "zarea" كما طلب المستخدم، ثم المفاتيح الأخرى
    final key = (dotenv.env['zarea'] ??
                 dotenv.env['smart_farmar2'] ??
                 dotenv.env['GROK_API_KEY'] ??
                 dotenv.env['XAI_API_KEY'] ??
                 '').trim();
    return key;
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final key = _apiKey;
    // اكتشاف المزود: Groq يبدأ بـ gsk_ أو يحتوي على gsk
    if (key.startsWith('gsk_') || key.contains('gsk')) {
      _currentBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
      // llama-3.1-8b-instant هو الأفضل والأكثر استقراراً للمستوى المجاني في Groq
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
      final promptData = await rootBundle.loadString('assets/ai/chatbot_prompt.json');
      final Map<String, dynamic> promptJson = jsonDecode(promptData);
      _systemInstruction = promptJson['system_instruction'];
    } catch (e) {
      debugPrint('GrokService: Error loading prompt, using default. $e');
      _systemInstruction = 'أنت المهندس زرعة، مستشار زراعي خبير في تطبيق زرعة. ردودك صارمة، مختصرة، ومنظمة جداً. إذا سُئلت عن شيء غير زراعي أو خارج التطبيق، اعتذر بوضوح.';
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
      messages.add({
        'role': msg['role'],
        'content': msg['content'],
      });
    }

    // بناء محتوى الرسالة (دعم النص والصورة)
    if (imageBytes != null && imageBytes.isNotEmpty) {
      // ضغط الصورة لتجنب مشكلة حجم البيانات الكبير
      Uint8List compressedBytes = Uint8List.fromList(imageBytes);
      try {
        final tempDir = await getTemporaryDirectory();
        final srcPath = '${tempDir.path}/src_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final targetPath = '${tempDir.path}/chat_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await File(srcPath).writeAsBytes(imageBytes);
        final result = await FlutterImageCompress.compressAndGetFile(
          srcPath,
          targetPath,
          minWidth: 800,
          minHeight: 800,
          quality: 80,
          format: CompressFormat.jpeg,
        );

        try { await File(srcPath).delete(); } catch (_) {}
        if (result != null) {
          compressedBytes = await result.readAsBytes();
          try { await File(targetPath).delete(); } catch (_) {}
        }
      } catch (e) {
        debugPrint('GrokService: Image compression failed: $e');
      }

      final base64Image = await compute(_encodeBase64, compressedBytes);
      String visionModel = _apiKey.contains('gsk') 
          ? 'llama-3.2-11b-vision-preview' // موديل الرؤية الأفضل في Groq حالياً
          : 'grok-2-vision-1212';
          
      messages.add({
        'role': 'user',
        'content': [
          if (message.isNotEmpty) {'type': 'text', 'text': message},
          {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}}
        ]
      });

      yield* _makeRequest(_currentBaseUrl, visionModel, messages);
    } else {
      messages.add({'role': 'user', 'content': message});
      
      bool success = false;
      String lastError = '';

      for (final model in [_currentPrimaryModel, _currentFallbackModel]) {
        try {
          await for (final chunk in _makeRequest(_currentBaseUrl, model, messages)) {
            if (chunk.startsWith('ERROR:')) {
              lastError = chunk.replaceFirst('ERROR:', '');
              if (lastError.contains('400') || lastError.contains('404')) break;
              yield 'عذراً، حدث خطأ فني.';
              return;
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

  Stream<String> _makeRequest(String url, String model, List<Map<String, dynamic>> messages) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        url,
        data: {
          'model': model,
          'messages': messages,
          'temperature': 0.1, // تقليل درجة الحرارة ليكون أكثر صرامة ودقة
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
              final chunk = decoded['choices']?[0]?['delta']?['content'] as String?;
              if (chunk != null) yield chunk;
            } catch (_) {}
          }
        }
      } else {
        yield 'ERROR:فشل الطلب (${response.statusCode})';
      }
    } on DioException catch (e) {
      final errorBody = e.response?.data?.toString() ?? e.message;
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
