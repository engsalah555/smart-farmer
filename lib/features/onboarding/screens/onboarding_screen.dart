import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/atoms/custom_button.dart';
import 'package:go_router/go_router.dart';
import '../../../core/assets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'نظام الزراعة الذكي',
      'description':
          'راقب مزرعتك عن بعد وتحكم في معداتك بكل سهولة ويسر من خلال هاتفك.',
      'image': AppAssets.onboarding1,
    },
    {
      'title': 'تحليلات مباشرة',
      'description':
          'احصل على معلومات دقيقة حول رطوبة التربة ودرجة الحرارة وغيرها من البيانات الهامة لمزرعتك.',
      'image': AppAssets.onboarding2,
    },
    {
      'title': 'تحكم آلي كامل',
      'description':
          'قم بضبط جداول الري وأتمتة المهام الزراعية الخاصة بك لتوفير الوقت والجهد.',
      'image': AppAssets.onboarding3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to Login
                    context.go('/auth');
                  },
                  child: const Text(
                    'تخطي',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration
                          Container(
                            height: 300,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Image.asset(
                              _pages[index]['image']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            _pages[index]['title']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _pages[index]['description']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: context.primary,
                  dotColor: const Color(0xFFE0E0E0),
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 4,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _currentPage == _pages.length - 1
                      ? 'ابدأ الآن'
                      : 'التالي',
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      context.go('/auth');
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
