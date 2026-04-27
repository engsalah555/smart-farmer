import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/models/crop_model.dart';
import '../../../features/crops/utils/crop_constants.dart';
import '../providers/crops_provider.dart';
import 'crop_card.dart';
import 'category_filters.dart';

class CropsGuideTab extends StatefulWidget {
  final bool isDark;
  final String searchQuery;

  const CropsGuideTab({
    super.key,
    required this.isDark,
    required this.searchQuery,
  });

  @override
  State<CropsGuideTab> createState() => _CropsGuideTabState();
}

class _CropsGuideTabState extends State<CropsGuideTab> {
  String _selectedFilter = 'الكل';
  final List<String> _filters = CropConstants.categoryIcons.keys.toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropsProvider>().fetchPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CropsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.allPlants.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: context.primary),
          );
        }

        List<Crop> currentCrops = provider.allPlants;

        // Category Filter
        if (_selectedFilter != 'الكل') {
          currentCrops = currentCrops
              .where((c) => c.category == _selectedFilter)
              .toList();
        }

        // Search Filter
        if (widget.searchQuery.isNotEmpty) {
          final query = widget.searchQuery.toLowerCase();
          currentCrops = currentCrops
              .where(
                (c) =>
                    c.name.toLowerCase().contains(query) ||
                    (c.scientificName?.toLowerCase().contains(query) ?? false),
              )
              .toList();
        }

        return RefreshIndicator(
          color: context.primary,
          onRefresh: () async => provider.fetchPlants(),
          child: CustomScrollView(
            slivers: [
              // Category Chips
              SliverToBoxAdapter(
                child: CategoryFilterChips(
                  selectedFilter: _selectedFilter,
                  filters: _filters,
                  isDark: widget.isDark,
                  onFilterChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              ),

              // Grid Content
              if (currentCrops.isEmpty)
                _buildEmptyState()
              else
                _buildCropsGrid(currentCrops),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على نتائج',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (widget.searchQuery.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  context.read<CropsProvider>().searchLivePlant(
                    widget.searchQuery,
                  );
                },
                icon: const Icon(Icons.travel_explore_rounded),
                label: const Text('ابحث في الدليل العالمي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() {
                _selectedFilter = 'الكل';
              }),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة ضبط الفلاتر'),
              style: TextButton.styleFrom(foregroundColor: context.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropsGrid(List<Crop> crops) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return FadeInSlide(
            duration: const Duration(milliseconds: 600),
            delay: Duration(milliseconds: index * 50),
            child: CropCard(crop: crops[index], isDark: widget.isDark),
          );
        }, childCount: crops.length),
      ),
    );
  }
}
