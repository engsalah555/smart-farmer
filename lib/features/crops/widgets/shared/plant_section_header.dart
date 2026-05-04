import 'package:flutter/material.dart';

/// Section header with optional TTS (text-to-speech) speaker button.
class PlantSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color; // unused but kept for api compatibility
  final VoidCallback? onSpeak;

  const PlantSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black.withValues(alpha: 0.8),
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (onSpeak != null)
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onSpeak,
                icon: Icon(
                  Icons.volume_up_rounded,
                  color: primaryColor.withValues(alpha: 0.8),
                ),
                tooltip: 'استمع للقراءة الصوتية',
                iconSize: 22,
              ),
            ),
        ],
      ),
    );
  }
}
