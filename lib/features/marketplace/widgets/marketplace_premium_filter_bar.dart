import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'premium_filter_chip.dart';

class MarketplacePremiumFilterBar extends StatefulWidget {
  final Function(String) onFilterSelected;
  final String selectedFilter;

  const MarketplacePremiumFilterBar({
    super.key,
    required this.onFilterSelected,
    required this.selectedFilter,
  });

  @override
  State<MarketplacePremiumFilterBar> createState() =>
      _MarketplacePremiumFilterBarState();
}

class _MarketplacePremiumFilterBarState
    extends State<MarketplacePremiumFilterBar> {
  final List<Map<String, dynamic>> filters = [
    {
      'id': 'trending',
      'label': 'الأكثر رواجاً',
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'id': 'nearest',
      'label': 'الأقرب إليك',
      'icon': Icons.location_on_rounded,
    },
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

          return PremiumFilterChip(
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
