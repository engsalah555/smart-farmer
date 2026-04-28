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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (onSpeak != null)
            IconButton(
              onPressed: onSpeak,
              icon: Icon(
                Icons.volume_up_rounded,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              tooltip: 'استمع للقراءة الصوتية',
              iconSize: 24,
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
        ],
      ),
    );
  }
}
