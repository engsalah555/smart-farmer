import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';

class MarketplacePremiumFilterBar extends StatefulWidget {
  final Function(String) onFilterSelected;
  final String selectedFilter;

  const MarketplacePremiumFilterBar({
    super.key,
    required this.onFilterSelected,
    required this.selectedFilter,
  });

  @override
  State<MarketplacePremiumFilterBar> createState() => _MarketplacePremiumFilterBarState();
}

class _MarketplacePremiumFilterBarState extends State<MarketplacePremiumFilterBar> {
  final List<Map<String, dynamic>> filters = [
    {'id': 'trending', 'label': 'الأكثر رواجاً', 'icon': Icons.local_fire_department_rounded},
    {'id': 'nearest', 'label': 'الأقرب إليك', 'icon': Icons.location_on_rounded},
    {'id': 'top_rated', 'label': 'الأعلى تقييماً', 'icon': Icons.star_rounded},
    {'id': 'newest', 'label': 'وصل حديثاً', 'icon': Icons.auto_awesome_rounded},
    {'id': 'offers', 'label': 'عروض حصرية', 'icon': Icons.local_offer_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = widget.selectedFilter == filter['id'];
          
          return _FilterChip(
            label: filter['label'],
            icon: filter['icon'],
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onFilterSelected(filter['id']);
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
