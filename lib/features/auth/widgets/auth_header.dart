import 'package:flutter/material.dart';
import '../../../core/widgets/fade_in_slide.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;

  const AuthHeader({
    super.key,
    this.title = 'المزارع الذكي',
    this.subtitle = 'نزرع المستقبل',
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, bottom: 90, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF76C748), Color(0xFF2D6A4F)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: FadeInSlide(
        duration: const Duration(milliseconds: 600),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Internal Back Button if enabled
            if (showBackButton)
              Positioned(
                top: 0,
                right: 0, // RTL
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

            // Background Icons Decorative
            Positioned(
              right: -40,
              top: -40,
              child: Icon(
                Icons.eco,
                size: 200,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              left: -40,
              bottom: 0,
              child: Icon(
                Icons.spa,
                size: 120,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.green.shade50.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
