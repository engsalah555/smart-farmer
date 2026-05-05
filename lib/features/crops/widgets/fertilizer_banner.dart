import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_typography.dart';

class FertilizerCalculatorBanner extends StatelessWidget {
  const FertilizerCalculatorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: () => context.push('/fertilizer_calculator'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration(isDark: isDark).copyWith(
            color: context.primary,
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: context.primary
                    .withValues(alpha: context.opacityMedium * 1.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -40,
                top: -40,
                child: Icon(
                  Icons.science_outlined,
                  size: 140,
                  color:
                      context.white.withValues(alpha: context.opacitySubtle * 1.6),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.white.withValues(
                        alpha: (context.opacityLow + context.opacityMedium) / 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حاسبة السماد الذكية',
                          style: AppTypography.h3(isDark: false).copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'نظام التوصيات العلمية المبني على نوع المحصول والتربة',
                          style: AppTypography.bodySmall(isDark: false).copyWith(
                            color: context.white
                                .withValues(alpha: context.opacityHigh / 1.15),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

