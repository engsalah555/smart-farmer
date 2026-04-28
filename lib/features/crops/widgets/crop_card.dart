import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/models/crop_model.dart';
import '../../../features/crops/utils/crop_constants.dart';
import '../../../core/theme/app_colors.dart';

class CropCard extends StatefulWidget {
  final Crop crop;
  final bool isDark;

  const CropCard({super.key, required this.crop, required this.isDark});

  @override
  State<CropCard> createState() => _CropCardState();
}

class _CropCardState extends State<CropCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _controller.forward();
  }

  void _onTapUp(_) {
    _controller.reverse();
    context.push('/crop_detail', extra: widget.crop);
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final crop = widget.crop;
    final isDark = widget.isDark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: Semantics(
        label: 'بطاقة المحصول: ${crop.name}. التصنيف: ${crop.category}',
        button: true,
        onTapHint: 'عرض تفاصيل المحصول',
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.5)
                    : context.primary.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.2 : 0.05,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Image Section ---
                Expanded(
                  flex: 5,
                  child: Hero(
                    tag: 'crop-${crop.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: CustomImage(
                            imageUrl: crop.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Simple Gradient for readability
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Minimal Badges
                        Positioned(
                          top: 8,
                          right: 8,
                          left: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCompactBadge(
                                icon: Icons.water_drop_rounded,
                                label: _getWaterLabel(crop.waterNeeds),
                                color: Colors.blueAccent,
                                isDark: isDark,
                              ),
                              _buildCompactBadge(
                                icon: Icons.wb_sunny_rounded,
                                label: _getSunlightShortLabel(
                                  crop.sunlightRequirement,
                                ),
                                color: Colors.amber,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // --- Info Section ---
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            crop.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CropConstants.categoryIcons[crop.category] ??
                                          Icons.eco_rounded,
                                      size: 12,
                                      color: context.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        crop.category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: context.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: context.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactBadge({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _getWaterLabel(String needs) {
    if (needs.contains('كثير') || needs.contains('عالي')) return 'مكثف';
    if (needs.contains('متوسط')) return 'معتدل';
    if (needs.contains('قليل')) return 'قليل';
    return 'معتدل';
  }

  String _getSunlightShortLabel(String? req) {
    if (req == null) return 'شمس';
    if (req.contains('كامل')) return 'مباشر';
    if (req.contains('ظل')) return 'جزئي';
    return 'خفيف';
  }
}
