import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/fade_in_slide.dart';

class SettingsInfoScreen extends StatelessWidget {
  final String title;
  final String content;

  const SettingsInfoScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTypography.h3(isDark: isDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInSlide(
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border(isDark), width: 1),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Text(
                  content,
                  style: AppTypography.bodyLarge(
                    isDark: isDark,
                  ).copyWith(height: 1.8, letterSpacing: 0.2),
                ),
              ),
            ),
            const SizedBox(height: 48),
            FadeInSlide(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'آخر تحديث: 25 أبريل 2026',
                      style: AppTypography.bodySmall(isDark: isDark).copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
