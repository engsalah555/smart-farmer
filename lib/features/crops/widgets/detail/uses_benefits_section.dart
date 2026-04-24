import 'package:flutter/material.dart';
import '../../../../core/models/crop_model.dart';
import '../../../../core/utils/responsive.dart';
import '../shared/plant_section_header.dart';

/// Uses & Benefits section
class UsesBenefitsSection extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onSpeak;

  const UsesBenefitsSection({super.key, required this.crop, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF2E7D32);

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
          color: primaryColor,
          onSpeak: onSpeak,
        ),

        if (crop.uses != null)
          _TextCard(text: crop.uses!, color: primaryColor, isDark: isDark),

        if (crop.benefits != null) ...[
          SizedBox(height: context.hp(1.5)),
          _TextCard(
            text: crop.benefits!,
            color: Colors.teal,
            isDark: isDark,
          ),
        ],

        if (crop.growthGuide != null) ...[
          SizedBox(height: context.hp(1.5)),
          _TextCard(
            text: crop.growthGuide!,
            color: Colors.indigo,
            isDark: isDark,
          ),
        ],
      ],
    );
  }
}

class _TextCard extends StatelessWidget {
  final String text;
  final Color color;
  final bool isDark;
  const _TextCard({
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.wp(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(context.wp(4)),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.sp(13),
          color: isDark ? Colors.white70 : Colors.black87,
          height: 1.7,
        ),
      ),
    );
  }
}
