import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'custom_image.dart';

/// A unified avatar component used across the app (Profile, Community, Marketplace)
/// to maintain a consistent visual identity for user profile pictures and store logos.
class UnifiedProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? localImage;
  final double radius;
  final double borderWidth;
  final Color? borderColor;
  final IconData placeholderIcon;
  final bool hasShadow;

  const UnifiedProfileAvatar({
    super.key,
    this.imageUrl,
    this.localImage,
    this.radius = 50,
    this.borderWidth = 4,
    this.borderColor,
    this.placeholderIcon = Icons.person,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderColor = borderColor ?? AppColors.primary.withValues(alpha: 0.2);
    final totalSize = (radius * 2) + (borderWidth * 2);

    return Container(
      width: totalSize,
      height: totalSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: ClipOval(
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (localImage != null) {
      return Image.file(
        localImage!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
      );
    }
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CustomImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
      );
    }

    return Icon(
      placeholderIcon,
      size: radius * 1.2,
      color: AppColors.primary,
    );
  }
}
