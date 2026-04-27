import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/models/post_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../../../core/helpers/image_helper.dart';

class CreatePostScreen extends StatefulWidget {
  final PostModel? postToEdit;
  const CreatePostScreen({super.key, this.postToEdit});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _removeExistingImage = false;
  int _charCount = 0;
  static const int _maxChars = 1000;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      _contentController.text = widget.postToEdit!.content;
      _existingImageUrl = widget.postToEdit!.postImage;
      _charCount = _contentController.text.length;
    }
    _contentController.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    setState(() {
      _charCount = _contentController.text.length;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    HapticFeedback.mediumImpact();
    try {
      final image = await ImageHelper.pickImage(
        context: context,
        source: source,
        cropStyle: CropStyle.rectangle,
        aspectRatios: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _existingImageUrl = null;
          _removeExistingImage = true;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedImage = null;
      if (_existingImageUrl != null) {
        _existingImageUrl = null;
        _removeExistingImage = true;
      }
    });
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateCharCount);
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      HapticFeedback.vibrate();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final authorName = authProvider.currentUser?.name ?? 'مستخدم زائر';

      if (widget.postToEdit != null) {
        await context.read<PostProvider>().editPost(
          widget.postToEdit!.id,
          content,
          title: content.length > 30
              ? '${content.substring(0, 30)}...'
              : content,
          imageFile: _selectedImage,
          removeImage: _removeExistingImage,
        );
      } else {
        final post = PostModel(
          id: '',
          userId: authProvider.currentUser?.id ?? '',
          author: authorName,
          time: DateTime.now().toIso8601String(),
          title: content.length > 30
              ? '${content.substring(0, 30)}...'
              : content,
          content: content,
          likesCount: 0,
          commentsCount: 0,
        );

        await context.read<PostProvider>().addPost(
          post,
          imageFile: _selectedImage,
        );
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/community');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  widget.postToEdit != null
                      ? 'تم تعديل المنشور بنجاح'
                      : 'تم نشر المنشور بنجاح',
                  style: const TextStyle(),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text('حدث خطأ أثناء النشر: $e', style: const TextStyle()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: context.wp(4.5)),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/forum');
              }
            },
          ),
          title: Text(
            widget.postToEdit != null ? 'تعديل المنشور' : 'منشور جديد',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: context.sp(20).clamp(18, 24),

              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.background,
          elevation: 0,
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(2),
                vertical: 8,
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.postToEdit != null ? 'تحديث' : 'نشر',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.wp(5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserHeader(context),
                      SizedBox(height: context.hp(1)),

                      TextField(
                        controller: _contentController,
                        maxLength: _maxChars,
                        autofocus: widget.postToEdit == null,
                        decoration: InputDecoration(
                          hintText: 'بماذا تفكر؟ شاركنا يومياتك الزراعية...',
                          border: InputBorder.none,
                          counterText: '',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: context.sp(17).clamp(15, 20),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        maxLines: null,
                        minLines: 5,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          fontSize: context.sp(16).clamp(14, 18),
                          height: 1.6,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      
                      if (_selectedImage != null || _existingImageUrl != null) ...[
                        SizedBox(height: context.hp(2)),
                        _buildImagePreview(context),
                      ],

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: context.hp(2)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (_charCount > _maxChars * 0.9 ? Colors.orange : Colors.grey).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_charCount / $_maxChars',
                                style: TextStyle(
                                  fontSize: context.sp(11).clamp(9, 13),
                                  fontWeight: FontWeight.w600,
                                  color: _charCount > _maxChars * 0.9 
                                      ? Colors.orange 
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Community Tips
                      Container(
                        padding: EdgeInsets.all(context.wp(4)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 18),
                            ),
                            SizedBox(width: context.wp(3)),
                            Expanded(
                              child: Text(
                                'نصيحة: المنشورات المدعمة بالصور تحصل على تفاعل أكبر بـ 3 أضعاف!',
                                style: TextStyle(
                                  fontSize: context.sp(13).clamp(11, 15),
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.hp(4)),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        return Container(
          padding: EdgeInsets.symmetric(vertical: context.hp(2)),
          child: Row(
            children: [
              CircleAvatar(
                radius: context.wp(5.5),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: user?.profileImage != null && user!.profileImage!.isNotEmpty
                    ? CachedNetworkImageProvider(user.profileImage!)
                    : null,
                child: user?.profileImage == null || user!.profileImage!.isEmpty
                    ? Icon(Icons.person, color: AppColors.primary, size: context.wp(6))
                    : null,
              ),
              SizedBox(width: context.wp(3)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'مستخدم زائر',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: context.sp(16).clamp(14, 18),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.public, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'منشور عام',
                        style: TextStyle(
                          fontSize: context.sp(11).clamp(10, 13),
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: context.hp(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: _existingImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            left: context.wp(4),
            right: context.wp(4),
            top: context.hp(1),
            bottom: context.hp(1) + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.8) 
                : Colors.white.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildToolButton(
                context,
                Icons.image_rounded,
                'صورة',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                context,
                Icons.camera_alt_rounded,
                'كاميرا',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.wp(4),
          vertical: context.hp(1),
        ),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.primary, size: context.wp(5)),
            SizedBox(width: context.wp(2)),
            Text(
              label,
              style: TextStyle(
                color: context.primary,
                fontSize: context.sp(14).clamp(12, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
