import 'package:flutter/material.dart';
import '../../constants.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewsCount;
  final bool showText;
  final double scale;

  const RatingBadge({
    super.key,
    required this.rating,
    this.reviewsCount,
    this.showText = true,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 10 * scale : 6 * scale, 
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurface.withValues(alpha: 0.95) 
            : const Color(0xFF1A1A1A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15), 
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded, 
            color: const Color(0xFFFFD700), 
            size: 14 * scale,
          ),
          if (showText) ...[
            SizedBox(width: 4 * scale),
            Text(
              rating > 0 ? rating.toStringAsFixed(1) : '—',
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w900, 
                fontSize: 12 * scale, 
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
