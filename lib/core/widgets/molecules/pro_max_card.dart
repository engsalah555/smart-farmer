import 'package:flutter/material.dart';
import '../../constants.dart';

class ProMaxCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  @Deprecated('Use boxShadow from softShadow() instead')
  final double? elevation;

  const ProMaxCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 22.0,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? AppColors.darkCard : AppColors.surface);
    final borderColor = AppColors.border(isDark);

    Widget content = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: content,
          ),
        ),
      );
    }

    return Padding(padding: margin ?? EdgeInsets.zero, child: content);
  }
}
