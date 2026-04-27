import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProMaxTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final double borderRadius;

  const ProMaxTextField({
    super.key,
    this.controller,
    required this.hint,
    required this.icon,
    this.inputType = TextInputType.text,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = AppColors.border(isDark);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Semantics(
      label: hint,
      textField: true,
      child: Container(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor),
        ),
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          obscureText: obscureText,
          textAlign: TextAlign.right,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Icon(icon, color: context.primary, size: 22),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: hintColor,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ),
    );
  }
}
