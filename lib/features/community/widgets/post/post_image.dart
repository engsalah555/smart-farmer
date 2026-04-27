import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/post_model.dart';
import '../../../../core/utils/responsive.dart';

class PostImage extends StatelessWidget {
  final PostModel post;

  const PostImage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.postImage == null || post.postImage!.isEmpty) {
      return const SizedBox.shrink();
    }

    final isLocalFile = !post.postImage!.startsWith('http') && !post.postImage!.startsWith('https');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(4),
        vertical: context.hp(1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Hero(
          tag: 'post_image_${post.id}',
          child: isLocalFile
              ? Image.file(
                  File(post.postImage!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => _buildImageError(context),
                )
              : CachedNetworkImage(
                  imageUrl: post.postImage!,
                  memCacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).toInt(),
                  placeholder: (context, url) => _buildShimmer(context),
                  errorWidget: (context, url, error) => _buildImageError(context),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildImageError(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 32),
          const SizedBox(height: 8),
          Text(
            'فشل تحميل الصورة',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
