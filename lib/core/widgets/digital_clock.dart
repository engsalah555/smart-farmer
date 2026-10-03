import 'dart:async';
import 'package:flutter/material.dart';

/// ساعة رقمية عصرية وواضحة بتصميم كبسولة أنيق بدون ظلال ضبابية
class DigitalClock extends StatefulWidget {
  final Color? color;
  final double fontSize;
  final bool showShadow;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;

  const DigitalClock({
    super.key,
    this.color,
    this.fontSize = 13,
    this.showShadow = false,
    this.showIcon = true,
    this.padding,
    this.decoration,
  });

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late DateTime _now;
  late StreamSubscription<int> _timerSubscription;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timerSubscription =
        Stream.periodic(const Duration(seconds: 1), (i) => i).listen((_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color contentColor = widget.color ?? Colors.white;

    final String period = _now.hour < 12 ? 'ص' : 'م';
    int hour = _now.hour > 12 ? _now.hour - 12 : _now.hour;
    if (hour == 0) hour = 12;
    final String hourStr = hour.toString().padLeft(2, '0');
    final String minuteStr = _now.minute.toString().padLeft(2, '0');

    return Container(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: widget.decoration ??
          BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.32),
              width: 1.0,
            ),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showIcon) ...[
            Icon(
              Icons.schedule_rounded,
              size: widget.fontSize * 1.12,
              color: contentColor.withValues(alpha: 0.95),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            '$hourStr:$minuteStr',
            style: TextStyle(
              color: contentColor,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 0.5,
              ),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: contentColor,
                fontSize: widget.fontSize * 0.72,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
