import 'dart:async';
import 'package:flutter/material.dart';

/// ساعة رقمية بنبض نيون تتغير ألوانها حسب وقت اليوم (ليلاً/نهاراً)
class DigitalClock extends StatefulWidget {
  final Color? color;
  final double fontSize;
  
  const DigitalClock({
    super.key,
    this.color,
    this.fontSize = 16,
  });

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> with SingleTickerProviderStateMixin {
  late DateTime _now;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late StreamSubscription _timerSubscription;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // تحديث كل ثانية للساعة
    _timerSubscription = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNight = _now.hour >= 18 || _now.hour < 6;
    final Color themeColor = widget.color ?? (isNight ? Colors.blueAccent : Colors.white);
    
    final String period = _now.hour < 12 ? 'ص' : 'م';
    int hour = _now.hour > 12 ? _now.hour - 12 : _now.hour;
    if (hour == 0) hour = 12;
    final String hourStr = hour.toString().padLeft(2, '0');
    final String minuteStr = _now.minute.toString().padLeft(2, '0');

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.2 * _pulseAnimation.value),
                blurRadius: 10 * _pulseAnimation.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$hourStr:$minuteStr',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: themeColor,
                      blurRadius: 8 * _pulseAnimation.value,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                period,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize * 0.75,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
