import 'package:flutter/material.dart';
import 'dart:async';
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 40,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
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

    // الانتظار حتى اكتمال الأنيميشن
    final elapsed = _controller.lastElapsedDuration ?? Duration.zero;
    final remaining = const Duration(milliseconds: 1500) - elapsed;
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
      backgroundColor: context.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SmartFarmLogo.large(),
              ),
            ),
            const SizedBox(height: 10),
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
      ),
    );
  }
}
