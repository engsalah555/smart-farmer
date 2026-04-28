import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../shared/plant_section_header.dart';

/// Uses & Benefits section
class UsesBenefitsSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const UsesBenefitsSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasContent = crop.uses != null ||
        crop.benefits != null ||
        crop.growthGuide != null;

    if (!hasContent) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlantSectionHeader(
          title: 'الاستخدامات والفوائد',
          icon: Icons.menu_book_rounded,
          onSpeak: onSpeak,
        ),

        if (crop.uses != null) ...[
          Text(
            crop.uses!,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (crop.benefits != null) ...[
          Text(
            crop.benefits!,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (crop.growthGuide != null) ...[
          Text(
            crop.growthGuide!,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.7,
            ),
          ),
        ],
      ],
    );
  }
}
