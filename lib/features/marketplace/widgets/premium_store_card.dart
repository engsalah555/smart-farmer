import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/custom_image.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../../../core/widgets/molecules/pro_max_card.dart';
import '../../../core/models/store_model.dart';
import 'store_card_components.dart';

class PremiumStoreCard extends StatefulWidget {
  final StoreModel store;
  final int index;

  const PremiumStoreCard({super.key, required this.store, required this.index});

  @override
  State<PremiumStoreCard> createState() => _PremiumStoreCardState();
}

class _PremiumStoreCardState extends State<PremiumStoreCard>
    with TickerProviderStateMixin {
  late AnimationController _shineController;
  late AnimationController _pulseController;
  late Animation<double> _shineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _shineController.forward();
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = widget.store;

    return FadeInSlide(
      delay: Duration(milliseconds: 30 * widget.index),
      duration: const Duration(milliseconds: 400),
      child: ProMaxCard(
        onTap: () {
          HapticFeedback.selectionClick();
          _shineController.reset();
          _shineController.forward();
          context.push('/store_details', extra: store);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardW = constraints.maxWidth;
            final cardH = constraints.maxHeight;
            final scale = (cardW / 360).clamp(0.85, 1.25);
            final coverH = (cardH * 0.60).clamp(100.0, 180.0);
            final logoSize = (coverH * 0.42 * scale).clamp(42.0, 68.0);
            final halfLogo = logoSize / 2;

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StoreCoverSection(
                      store: store,
                      height: coverH,
                      scale: scale,
                      isDark: isDark,
                    ),
                    Expanded(
                      child: StoreInfoSection(
                        store: store,
                        isDark: isDark,
                        topPadding: halfLogo,
                        scale: scale,
                        horizontalPadding: (14.0 * scale).clamp(10.0, 18.0),
                        verticalPadding: (10.0 * scale).clamp(8.0, 14.0),
                      ),
                    ),
                  ],
                ),

                // Shine Effect
                AnimatedBuilder(
                  animation: _shineAnimation,
                  builder: (context, _) {
                    if (_shineAnimation.value <= -1.0 || _shineAnimation.value >= 2.0) {
                      return const SizedBox.shrink();
                    }
                    return PositionedDirectional(
                      top: 0,
                      start: _shineAnimation.value * cardW,
                      bottom: 0,
                      width: cardW * 0.4,
                      child: RepaintBoundary(
                        child: Transform.rotate(
                          angle: 0.5,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Logo with Status
                PositionedDirectional(
                  top: coverH - halfLogo,
                  start: 14,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildStoreLogo(store, logoSize, isDark),
                      PositionedDirectional(
                        bottom: 2,
                        end: 2,
                        child: RepaintBoundary(child: _buildStatusOrb()),
                      ),
                    ],
                  ),
                ),

                // Product Glimpse
                if (store.products.isNotEmpty && cardW > 300)
                  PositionedDirectional(
                    top: coverH + 10,
                    end: 12,
                    child: _buildProductGlimpse(store, scale, isDark),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusOrb() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CAF50),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: _pulseAnimation.value * 0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGlimpse(StoreModel store, double scale, bool isDark) {
    final products = store.products.take(3).toList();
    final itemSize = 22.0 * scale;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(products.length, (index) {
          return Padding(
            padding: EdgeInsetsDirectional.only(end: index == products.length - 1 ? 0 : 4),
            child: Container(
              width: itemSize,
              height: itemSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: ClipOval(
                child: CustomImage(
                  imageUrl: products[index].images.isNotEmpty ? products[index].images.first : '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStoreLogo(StoreModel store, double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.getSurface(isDark),
        border: Border.all(color: isDark ? AppColors.white.withValues(alpha: 0.1) : Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: store.logo.isNotEmpty
            ? CustomImage(imageUrl: store.logo, fit: BoxFit.cover)
            : Container(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.store_rounded, color: AppColors.primary, size: size * 0.45),
              ),
      ),
    );
  }
}
