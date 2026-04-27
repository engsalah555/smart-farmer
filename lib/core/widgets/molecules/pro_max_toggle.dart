import 'package:flutter/material.dart';
import '../app_fonts.dart';
import '../../constants.dart';

class ProMaxToggle extends StatelessWidget {
  final bool value;
  final String activeLabel;
  final String inactiveLabel;
  final Function(bool) onChanged;
  final double height;

  const ProMaxToggle({
    super.key,
    required this.value,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.onChanged,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.14),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: context.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildToggleItem(
            context,
            title: inactiveLabel,
            isActive: !value,
            onTap: () => onChanged(false),
          ),
          _buildToggleItem(
            context,
            title: activeLabel,
            isActive: value,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: context.font14.semiBold.copyWith(
                color: isActive
                    ? context.primary
                    : AppColors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
