import 'package:flutter/material.dart';
import '../../constants.dart';

class ProMaxIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final bool isGlass;
  final double? borderRadius; // Added to control shape

  const ProMaxIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.backgroundColor,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.isGlass = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Logic for circular vs rounded square
    final effectiveRadius = borderRadius ?? 12.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius == null && size > 0
              ? BorderRadius.circular(effectiveRadius)
              : (borderRadius != null
                    ? BorderRadius.circular(borderRadius!)
                    : BorderRadius.circular(size / 2)),
          border: Border.all(color: context.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: color ?? (isGlass ? Colors.white : context.primary),
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
