import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: color, size: size);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: color, size: size);
        } else {
          return Icon(
            Icons.star_border,
            color: color.withValues(alpha: 0.3),
            size: size,
          );
        }
      }),
    );
  }
}
