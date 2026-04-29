import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/services/locator.dart';
import '../services/gemini_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Uint8List>? images;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.images,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = locator<GeminiService>();
  final ImagePicker _picker = ImagePicker();

  final List<ChatMessage> _messages = [];
  XFile? _selectedImage;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message if list is empty
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          text: 'أهلاً بك في مساعدك الزراعي الذكي! كيف يمكنني مساعدتك اليوم؟',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  String _cleanResponse(String text) {
    // Remove Markdown asterisks as requested by the user
    // This replaces all occurrences of '*' with an empty string
    return text.replaceAll('*', '');
  }

  Future<void> _handleSendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final Uint8List? imageBytes = _selectedImage != null
        ? await _selectedImage!.readAsBytes()
        : null;
    final List<Uint8List>? displayImages = imageBytes != null
        ? [imageBytes]
        : null;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
          images: displayImages,
        ),
      );
      _messageController.clear();
      _selectedImage = null;
      _isTyping = true;
    });

    _scrollToBottom();

    // Prepare for streaming response
    String fullContent = '';
    ChatMessage botMessage = ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    // Add initial empty message
    setState(() {
      _messages.add(botMessage);
    });

    final int botMessageIndex = _messages.length - 1;

    try {
      final responseStream = _geminiService.sendMessageStream(
        text,
        imageBytes: imageBytes,
      );

      await for (final chunk in responseStream) {
        fullContent += chunk;
        if (mounted) {
          setState(() {
            if (botMessageIndex < _messages.length) {
              _messages[botMessageIndex] = ChatMessage(
                text: _cleanResponse(fullContent),
                isUser: false,
                timestamp: botMessage.timestamp,
              );
            }
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final index = _messages.indexOf(botMessage);
          _messages[index] = ChatMessage(
            text: 'عذراً، حدث خطأ أثناء الاتصال بالخادم. حاول مرة أخرى.',
            isUser: false,
            timestamp: botMessage.timestamp,
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.background,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/icon/icon.png'),
            opacity: isDark ? 0.02 : 0.03,
            repeat: ImageRepeat.repeat,
            scale: 5,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
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
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return FadeInSlide(
                          duration: const Duration(milliseconds: 400),
                          delay: Duration(
                            milliseconds: index == _messages.length - 1
                                ? 0
                                : 50,
                          ),
                          child: _buildMessageBubble(message),
                        );
                      },
                    ),
            ),
            if (_isTyping) _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: [
          BoxShadow(
            color: context.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: context.primary.withValues(alpha: 0.1),
            backgroundImage: const AssetImage('assets/icon/icon.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'استشاري زرعــة',
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
                    style: TextStyle(color: context.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bool isUser = message.isUser;
    return Container(
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
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? context.darkSurface
                  : context.white,
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
                if (message.images != null && message.images!.isNotEmpty)
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
                      message.images!.first,
                      width: 200,
                      cacheWidth: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser ? AppDecorations.primaryGradient : null,
                    color: isUser ? null : context.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? context.primary.withValues(alpha: 0.3)
                            : context.black.withValues(
                                alpha: context.isDark ? 0.2 : 0.05,
                              ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? context.white : context.textColor,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, "0")}',
                    style: TextStyle(color: context.textMuted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          FadeInSlide(
            duration: const Duration(milliseconds: 600),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: context.surface,
              backgroundImage: const AssetImage('assets/icon/icon.png'),
            ),
          ),
          const SizedBox(height: 24),
          FadeInSlide(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'الاستشاري الزراعي الذكي\nجاهز للتحليل',
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
        ],
      ),
    );
  }

  Widget _buildStarterGrid() {
    return Column(
      children: [
        _buildStarterCommand(
          'تشخيص الأمراض',
          Icons.bug_report_outlined,
          'كيف يمكنني تشخيص مرض في نبات الطماطم؟',
          delay: 0,
        ),
        const SizedBox(height: 8),
        _buildStarterCommand(
          'نصائح الري',
          Icons.water_drop_outlined,
          'ما هو أفضل وقت لري المحاصيل في الصيف؟',
          delay: 100,
        ),
        const SizedBox(height: 8),
        _buildStarterCommand(
          'التقويم الزراعي',
          Icons.calendar_month_outlined,
          'ماذا يمكنني أن أزرع في هذا الشهر؟',
          delay: 200,
        ),
        const SizedBox(height: 8),
        _buildStarterCommand(
          'حاسبة الأسمدة',
          Icons.calculate_outlined,
          'كيف أحسب كمية السماد اللازمة لمحصول القمح؟',
          delay: 300,
        ),
      ],
    );
  }

  Widget _buildStarterCommand(
    String title,
    IconData icon,
    String query, {
    required int delay,
  }) {
    return FadeInSlide(
      duration: const Duration(milliseconds: 500),
      delay: Duration(milliseconds: delay),
      beginOffset: const Offset(0, 0.2),
      child: Material(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _messageController.text = query;
            _handleSendMessage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: context.border.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: context.primary, size: 20),
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
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: 12,
                        ),
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
      ),
    );
  }

  Widget _buildTypingIndicator() {
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

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        children: [
          if (_selectedImage != null)
            FadeInSlide(
              beginOffset: const Offset(0, 0.5),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          File(_selectedImage!.path),
                          cacheWidth: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      PositionedDirectional(
                        top: -8,
                        start: -8,
                        child: GestureDetector(
                          onTap: _removeSelectedImage,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: context.error.withValues(
                              alpha: 0.9,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: context.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: context.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: context.isDark
                              ? context.primary
                              : context.textMuted,
                        ),
                        onPressed: _pickImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالتك هنا...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: context.textMuted,
                              fontSize: 14,
                            ),
                          ),
                          style: TextStyle(color: context.textColor),
                          minLines: 1,
                          maxLines: 4,
                          onSubmitted: (_) => _handleSendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _handleSendMessage,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.primary,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Icon(Icons.send_rounded, color: context.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double value = (index * 0.2 + _controller.value) % 1.0;
            final double offset = -6.0 * (0.5 - (value - 0.5).abs()) * 2.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              transform: Matrix4.translationValues(0, offset, 0),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: context.textMuted.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
