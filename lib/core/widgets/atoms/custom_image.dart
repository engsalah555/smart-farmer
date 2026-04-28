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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5), // Light grey like Instagram/Facebook backgrounds
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF0F2F5),
            const Color(0xFFE4E6EB),
          ],
        ),
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth > 0 ? constraints.maxWidth : (width ?? 50);
            return Opacity(
              opacity: 0.4,
              child: Icon(
                Icons.person_rounded, // Instagram style person silhouette
                color: const Color(0xFF8A8D91),
                size: size * 0.7,
              ),
            );
          },
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
