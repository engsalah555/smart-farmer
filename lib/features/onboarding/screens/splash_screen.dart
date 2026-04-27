import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/atoms/smart_farm_logo.dart';

import 'package:go_router/go_router.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/update_service.dart';
import '../../../core/widgets/organisms/update_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _stardustAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    // Timeline for stardust particles merging
    _stardustAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      ),
    );

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // البدء بفحص التحديثات في الخلفية
    final updateService = locator<UpdateService>();
    final updateInfo = await updateService.checkUpdate();

    if (updateInfo != null && mounted) {
      // إظهار حوار التحديث إذا كان متاحاً
      await showDialog(
        context: context,
        barrierDismissible: !updateInfo.forceUpdate,
        builder: (context) => UpdateDialog(updateInfo: updateInfo),
      );

      // إذا كان التحديث إلزامياً، لا نكمل التشغيل
      if (updateInfo.forceUpdate) return;
    }

    // الانتظار حتى اكتمال الأنيميشن (على الأقل 2.5 ثانية إجمالاً)
    final elapsed = _controller.lastElapsedDuration ?? Duration.zero;
    final remaining = const Duration(milliseconds: 2500) - elapsed;
    if (remaining.inMilliseconds > 0) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    // التحقق من حالة تسجيل الدخول
    final authProvider = context.read<AuthProvider>();

    // انتظار انتهاء تهيئة AuthProvider إذا كان لا يزال يحمّل
    if (authProvider.isLoading) {
      final deadline = DateTime.now().add(const Duration(seconds: 3));
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return authProvider.isLoading && DateTime.now().isBefore(deadline);
      });
    }

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/language');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Stardust particles merging effect
            AnimatedBuilder(
              animation: _stardustAnimation,
              builder: (context, child) {
                return Stack(
                  children: List.generate(30, (index) {
                    final random = math.Random(index);
                    final angle = random.nextDouble() * 2 * math.pi;
                    final distance = 250.0 * _stardustAnimation.value;
                    final size = random.nextDouble() * 5 + 2;

                    return Transform.translate(
                      offset: Offset(
                        math.cos(angle) * distance,
                        math.sin(angle) * distance,
                      ),
                      child: Opacity(
                        opacity: _stardustAnimation.value > 0.05 ? 0.8 : 0.0,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: context.primary.withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo (Adjusted dimensions for better fit)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const SmartFarmLogo(width: 250, height: 130),
                  ),
                ),
                const SizedBox(height: 10), // Reduced spacing
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(context.primary),
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
