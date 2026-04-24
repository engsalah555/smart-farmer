import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

/// Section header with optional TTS (text-to-speech) speaker button.
class PlantSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onSpeak;

  const PlantSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: context.hp(1.5)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.wp(2)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(context.wp(3)),
            ),
            child: Icon(icon, color: color, size: context.sp(18)),
          ),
          SizedBox(width: context.wp(3)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: context.sp(16),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Speaker button for TTS
          if (onSpeak != null)
            IconButton(
              onPressed: onSpeak,
              icon: Icon(
                Icons.volume_up_rounded,
                color: color.withValues(alpha: 0.7),
                size: context.sp(20),
              ),
              tooltip: 'استمع للقراءة الصوتية',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: context.wp(8),
                minHeight: context.wp(8),
              ),
            ),
        ],
      ),
    );
  }
}
