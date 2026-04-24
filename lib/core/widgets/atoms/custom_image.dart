import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String? fallbackAsset;
  final Widget? errorWidget;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.fallbackAsset,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildPremiumFallback();
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width != null ? (width! * 2).toInt() : 512,
        errorBuilder: (context, error, stackTrace) =>
            _buildPremiumFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      memCacheWidth: width != null ? (width! * 2).toInt() : 600,
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) => _buildPremiumFallback(),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildPremiumFallback() {
    // Generate a beautiful gradient based on the URL or Name if possible
    // For now, use a sophisticated brand-aligned gradient
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade400,
            Colors.green.shade700,
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.5,
          child: Icon(
            Icons.eco_outlined,
            color: Colors.white,
            size: (width ?? 40) / 2.5,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
