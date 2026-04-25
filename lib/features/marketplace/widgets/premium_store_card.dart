import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/models/store_model.dart';
import '../../../core/widgets/app_fonts.dart';
import '../../../core/widgets/fade_in_slide.dart';

class PremiumStoreCard extends StatelessWidget {
  final StoreModel store;
  final int index;

  const PremiumStoreCard({
    super.key,
    required this.store,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInSlide(
      duration: Duration(milliseconds: 400 + (index * 50)),
      beginOffset: const Offset(0, 0.1),
      child: GestureDetector(
        onTap: () => context.push('/store_details', extra: store),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.border.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image & Logo
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      // Cover
                      Positioned.fill(
                        child: Hero(
                          tag: 'store_cover_${store.id}',
                          child: Image.network(
                            store.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: context.primary.withValues(alpha: 0.05),
                              child: Icon(Icons.storefront_rounded, 
                                  color: context.primary.withValues(alpha: 0.3), size: 40),
                            ),
                          ),
                        ),
                      ),
                      // Premium Gradient Overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.6, 1.0],
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Logo (Floating Badge Style)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              store.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  Icon(Icons.person, color: context.primary),
                            ),
                          ),
                        ),
                      ),
                      // Category Tag (Brutalist Style)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: context.primary,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: context.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            store.category,
                            style: context.font10.bold.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.font16.bold.copyWith(
                            color: context.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: context.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                store.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.font12.medium.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: context.primary.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    store.rating.toStringAsFixed(1),
                                    style: context.font12.bold.copyWith(
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${store.reviewsCount})',
                                    style: context.font10.medium.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${store.productsCount} منتج',
                                style: context.font12.bold.copyWith(
                                  color: context.primary,
                                ),
                              ),
                            ],
                          ),
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
}
