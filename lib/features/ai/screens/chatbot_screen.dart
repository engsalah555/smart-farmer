import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/constants.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/services/locator.dart';
import '../services/grok_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? image;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.image,
  });

  ChatMessage copyWith({String? text}) => ChatMessage(
    text: text ?? this.text,
    isUser: isUser,
    timestamp: timestamp,
    image: image,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GrokService _grokService = locator<GrokService>();
  final ImagePicker _picker = ImagePicker();

  final List<ChatMessage> _messages = [];
  XFile? _selectedImage;
  bool _isTyping = false;

  // نتبع آخر فهرس رسالة بوت جارية (لتحديث متزامن بدون setState مكثف)
  int _botMessageIndex = -1;
  String _botAccumulated = '';

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: 'أهلاً بك في مساعدك الزراعي الذكي! كيف يمكنني مساعدتك اليوم؟',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  void _removeSelectedImage() {
    setState(() => _selectedImage = null);
  }

  String _cleanResponse(String text) => text.trim();

  List<Map<String, String>> _buildChatHistory() {
    final history = <Map<String, String>>[];
    for (int i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.text.isEmpty) continue;
      history.add({
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      });
    }
    // Limit to last 10 messages to avoid token limit and maintain speed
    if (history.length > 10) {
      return history.sublist(history.length - 10);
    }
    return history;
  }

  Future<void> _handleSendMessage() async {
    if (_isTyping) return;
    final String text = _messageController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    Uint8List? imageBytes;
    if (_selectedImage != null) {
      imageBytes = await _selectedImage!.readAsBytes();
    }

    final history = _buildChatHistory();

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
          image: imageBytes,
        ),
      );
      _messageController.clear();
      _selectedImage = null;
      _isTyping = true;

      // إضافة رسالة فارغة للبوت
      _botAccumulated = '';
      _messages.add(
        ChatMessage(text: '', isUser: false, timestamp: DateTime.now()),
      );
      _botMessageIndex = _messages.length - 1;
    });

    _scrollToBottom();

    try {
      await for (final chunk in _grokService.sendMessageStream(
        text,
        imageBytes: imageBytes,
        chatHistory: history,
      )) {
        _botAccumulated += chunk;
        if (mounted && _botMessageIndex < _messages.length) {
          // تحديث الرسالة بدون إعادة بناء القائمة بالكامل
          setState(() {
            _messages[_botMessageIndex] = _messages[_botMessageIndex].copyWith(
              text: _cleanResponse(_botAccumulated),
            );
          });
        }
      }
    } catch (e) {
      if (mounted && _botMessageIndex >= 0) {
        setState(() {
          _messages[_botMessageIndex] = _messages[_botMessageIndex].copyWith(
            text: 'عذراً، حدث خطأ أثناء الاتصال. حاول مرة أخرى.',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
        _scrollToBottom();
      }
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بدء محادثة جديدة'),
        content: const Text('هل أنت متأكد من رغبتك في مسح المحادثة الحالية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _messageController.clear();
                _selectedImage = null;
                _messages.add(
                  ChatMessage(
                    text:
                        'أهلاً بك في مساعدك الزراعي الذكي! كيف يمكنني مساعدتك اليوم؟',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
                _botMessageIndex = -1;
                _botAccumulated = '';
              });
            },
            child: const Text('نعم، امسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            _ChatAppBar(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              onClear: _clearChat,
            ),
            Expanded(
              child: _messages.length <= 1
                  ? _buildWelcomeState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      itemCount: _messages.length,
                      // addAutomaticKeepAlives = false يحسن الأداء مع قوائم طويلة
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        // FadeIn فقط على آخر رسالة
                        final isLatest = index == _messages.length - 1;
                        final bubble = _MessageBubble(
                          message: message,
                          key: ValueKey('msg_$index'),
                        );
                        if (isLatest && index > 0) {
                          return FadeInSlide(
                            duration: const Duration(milliseconds: 300),
                            child: bubble,
                          );
                        }
                        return bubble;
                      },
                    ),
            ),
            if (_isTyping) const _TypingIndicator(),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          FadeInSlide(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/icon/icon.png', width: 50, height: 50),
            ),
          ),
          const SizedBox(height: 24),
          FadeInSlide(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 150),
            child: Text(
              'الاستشاري الزراعي الذكي\nجاهز للمساعدة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.textColor,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildStarterGrid(),
          const SizedBox(height: 40),

          // New: Prominent Clear/New Chat button in welcome state
          if (_messages.length > 1)
            FadeInSlide(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 400),
              child: OutlinedButton.icon(
                onPressed: _clearChat,
                icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                label: const Text('بدء محادثة جديدة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.error,
                  side: BorderSide(color: context.error.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStarterGrid() {
    const items = [
      (
        'تشخيص الأمراض',
        Icons.bug_report_outlined,
        'كيف يمكنني تشخيص مرض في نبات الطماطم؟',
      ),
      (
        'نصائح الري',
        Icons.water_drop_outlined,
        'ما هو أفضل وقت لري المحاصيل في الصيف؟',
      ),
      (
        'التقويم الزراعي',
        Icons.calendar_month_outlined,
        'ماذا يمكنني أن أزرع في هذا الشهر؟',
      ),
      (
        'حاسبة الأسمدة',
        Icons.calculate_outlined,
        'كيف أحسب كمية السماد اللازمة لمحصول القمح؟',
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          FadeInSlide(
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: i * 80),
            beginOffset: const Offset(0, 0.15),
            child: _StarterItem(
              title: items[i].$1,
              icon: items[i].$2,
              query: items[i].$3,
              onTap: () {
                _messageController.text = items[i].$3;
                _handleSendMessage();
              },
            ),
          ),
          if (i < items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    // نستخدم MediaQuery للتأكد من عدم تداخل الأزرار مع شريط التنقل
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        bottomPadding > 0 ? bottomPadding : 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedImage != null)
                    FadeInSlide(
                      beginOffset: const Offset(0, 0.4),
                      child: _SelectedImagePreview(
                        image: _selectedImage!,
                        onRemove: _removeSelectedImage,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: 2,
                          start: 4,
                        ),
                        child: IconButton(
                          tooltip: 'إرفاق صورة',
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: context.primary,
                          ),
                          onPressed: _isTyping ? null : _pickImage,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isTyping,
                          decoration: InputDecoration(
                            hintText: 'اكتب سؤالك الزراعي هنا...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              color: context.textMuted,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsetsDirectional.only(
                              top: 14,
                              bottom: 14,
                              end: 16,
                            ),
                          ),
                          style: TextStyle(
                            color: context.textColor,
                            fontSize: 15,
                          ),
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSendMessage(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _SendButton(
            onTap: _handleSendMessage,
            controller: _messageController,
            hasImage: _selectedImage != null,
            isTyping: _isTyping,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets مع const وRepaintBoundary لتحسين الأداء
// ─────────────────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClear;
  const _ChatAppBar({required this.onBack, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.surface,
          boxShadow: [
            BoxShadow(
              color: context.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: onBack,
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: context.primary.withValues(alpha: 0.1),
              backgroundImage: const AssetImage('assets/icon/icon.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'استشاري زرعة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'متصل نشط',
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'بدء محادثة جديدة',
              icon: Icon(Icons.delete_sweep_outlined, color: context.error),
              onPressed: onClear,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: context.primary.withValues(alpha: 0.1),
                backgroundImage: const AssetImage('assets/icon/icon.png'),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (message.image != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: context.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(
                        message.image!,
                        width: 200,
                        cacheWidth: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (message.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? context.primary
                            : context.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: isUser
                          ? Text(
                              message.text,
                              style: TextStyle(
                                color: context.white,
                                fontSize: 15,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : MarkdownBody(
                              data: message.text,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  color: context.textColor,
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                                listBullet: TextStyle(
                                  color: context.primary,
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                                h1: TextStyle(color: context.textColor, fontSize: 20, fontWeight: FontWeight.bold),
                                h2: TextStyle(color: context.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                                h3: TextStyle(color: context.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                                strong: TextStyle(color: context.textColor, fontWeight: FontWeight.bold),
                                em: TextStyle(color: context.textColor, fontStyle: FontStyle.italic),
                              ),
                            ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: context.textMuted, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            if (isUser) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 20),
      child: Row(
        children: [
          const _BouncingDots(),
          const SizedBox(width: 8),
          Text(
            'جاري التفكير...',
            style: TextStyle(
              color: context.textMuted,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarterItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String query;
  final VoidCallback onTap;
  const _StarterItem({
    required this.title,
    required this.icon,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: context.border.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: context.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      query,
                      style: TextStyle(color: context.textMuted, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: context.textMuted.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;
  const _SelectedImagePreview({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(
        top: 16,
        start: 16,
        end: 16,
        bottom: 4,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              File(image.path),
              cacheWidth: 150,
              fit: BoxFit.cover,
            ),
          ),
          PositionedDirectional(
            top: -12,
            start: -12,
            child: GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  final TextEditingController controller;
  final bool hasImage;
  final bool isTyping;

  const _SendButton({
    required this.onTap,
    required this.controller,
    required this.hasImage,
    required this.isTyping,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isEnabled =
            !isTyping && (value.text.trim().isNotEmpty || hasImage);
        return Semantics(
          label: 'إرسال الرسالة',
          button: true,
          enabled: isEnabled,
          child: GestureDetector(
            onTap: isEnabled ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: isEnabled ? context.primary : context.surface,
                shape: BoxShape.circle,
                border: isEnabled ? null : Border.all(color: context.border),
              ),
              child: Icon(
                Icons.send_rounded,
                color: isEnabled
                    ? context.white
                    : context.textMuted.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BouncingDots — مُحسَّن: لا يُعيد بناء الشجرة بالكامل
// ─────────────────────────────────────────────────────────────────────────────

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double value = (_controller.value + index * 0.25) % 1.0;
            final double offset = -5.0 * (1 - (2 * value - 1).abs());
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              transform: Matrix4.translationValues(0, offset, 0),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: context.textMuted.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}
