import 'package:flutter/material.dart';
import '../../constants.dart';

class ProMaxCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool applyGradientBorder;
  final Color? backgroundColor;
  final double? elevation;

  const ProMaxCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 22.0,
    this.applyGradientBorder = false,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBgColor = isDark ? AppColors.darkCard : Colors.white;
    final bgColor = backgroundColor ?? defaultBgColor;

    final border = applyGradientBorder
        ? null
        : Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.6)
                : AppColors.primary.withValues(alpha: 0.05),
            width: 1.2,
          );

    Decoration decoration = BoxDecoration(
      color: applyGradientBorder ? null : bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.08),
          blurRadius: elevation != null ? elevation! * 4 : 16,
          offset: Offset(0, elevation != null ? elevation! * 1.5 : 6),
        ),
        if (!isDark && (elevation == null || elevation! > 0))
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: elevation != null ? elevation! * 2 : 6,
            offset: Offset(0, elevation != null ? elevation! * 0.5 : 2),
          ),
      ],
      border: border,
    );

    Widget content = Container(
      padding: padding,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );

    if (applyGradientBorder) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius + 2),
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: child,
          ),
        ),
      );
    }

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

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: content,
    );
  }
}
