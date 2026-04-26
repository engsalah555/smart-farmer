import 'package:flutter/material.dart';

enum FadeInSlideDirection {
  ttb, // top to bottom
  btt, // bottom to top
  ltr, // left to right
  rtl, // right to left
}

class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset? beginOffset;
  final FadeInSlideDirection direction;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.beginOffset,
    this.direction = FadeInSlideDirection.btt,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Determine begin offset based on direction if not explicitly provided
    final effectiveOffset = widget.beginOffset ?? _getOffsetForDirection(widget.direction);

    _slideAnimation = Tween<Offset>(
      begin: effectiveOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    final actualDelay =
        widget.delay.inMilliseconds > 500 ? const Duration(milliseconds: 500) : widget.delay;

    if (actualDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(actualDelay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  Offset _getOffsetForDirection(FadeInSlideDirection direction) {
    switch (direction) {
      case FadeInSlideDirection.ttb:
        return const Offset(0, -0.2);
      case FadeInSlideDirection.btt:
        return const Offset(0, 0.2);
      case FadeInSlideDirection.ltr:
        return const Offset(-0.2, 0);
      case FadeInSlideDirection.rtl:
        return const Offset(0.2, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
