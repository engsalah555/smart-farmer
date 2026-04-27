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
    // Logic for circular vs rounded square
    final effectiveRadius = borderRadius ?? (size / 2);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(effectiveRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: Center(
            child: Icon(
              icon,
              color: color ?? (isGlass ? Colors.white : context.primary),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
