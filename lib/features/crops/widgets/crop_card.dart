import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/molecules/glassmorphic_container.dart';
import '../../../core/models/crop_model.dart';
import '../../../features/crops/utils/crop_constants.dart';
import '../screens/crop_detail_screen.dart';

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
  bool _isPressed = false;

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
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(_) {
    setState(() => _isPressed = false);
    _controller.reverse();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropDetailScreen(crop: widget.crop),
      ),
    );
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
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
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.6)
                  : AppColors.primary.withValues(alpha: 0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _isPressed ? 0.15 : 0.08,
                ),
                blurRadius: _isPressed ? 12 : 24,
                spreadRadius: _isPressed ? 0 : -4,
                offset: Offset(0, _isPressed ? 4 : 12),
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Image Section with Badges ───
              Expanded(
                flex: 5,
                child: Hero(
                  tag: 'crop-${crop.id}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: CustomImage(
                          imageUrl: crop.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Premium Gradient Overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.4, 1.0],
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: isDark ? 0.85 : 0.60),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Top Badges
                      Positioned(
                        top: 10,
                        right: 10,
                        left: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFlatBadge(
                              context,
                              icon: Icons.water_drop_rounded,
                              label: _getWaterLabel(crop.waterNeeds),
                              color: Colors.blueAccent,
                              isDark: isDark,
                            ),
                            _buildFlatBadge(
                              context,
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
              // ─── Info Section (Glass Slab) ───
              Expanded(
                flex: 3,
                child: GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: AppColors.getSurface(isDark),
                  opacity: isDark ? 0.6 : 0.85,
                  blur: 15.0,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.08) 
                          : AppColors.primary.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        crop.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          letterSpacing: -0.5,
                          height: 1.1,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.22),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CropConstants.categoryIcons[crop.category] ??
                                      Icons.eco_rounded,
                                  size: 11,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  crop.category,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Cairo',
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow button (Enhanced Glow)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 12,
                              textDirection: TextDirection.ltr,
                            ),
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
    );
  }

  Widget _buildFlatBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: BorderRadius.circular(10),
      color: AppColors.getSurface(isDark),
      opacity: isDark ? 0.5 : 0.8,
      blur: 8.0,
      border: Border.all(
        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.5),
        width: 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 0.5,
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
