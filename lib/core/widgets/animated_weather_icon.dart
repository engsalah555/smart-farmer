import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWeatherIcon extends StatefulWidget {
  final int code;
  final bool isDay;
  final double size;
  final Color? color;

  const AnimatedWeatherIcon({
    super.key,
    required this.code,
    required this.isDay,
    this.size = 80,
    this.color,
  });

  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.code == 0) {
      // Clear/Sunny
      return _buildSunny();
    } else if (widget.code >= 1 && widget.code <= 3) {
      // Partly cloudy / Cloudy
      return _buildCloudy();
    } else if (widget.code >= 51 && widget.code <= 65) {
      // Rain / Drizzle
      return _buildRainy();
    } else if (widget.code >= 71 && widget.code <= 75) {
      // Snow
      return _buildSnowy();
    } else if (widget.code >= 95) {
      // Thunderstorm
      return _buildStormy();
    } else {
      // Default / Unknown
      return _buildCloudy();
    }
  }

  Widget _buildSunny() {
    final baseColor = widget.color ?? (widget.isDay ? Colors.amber : Colors.blueGrey.shade100);
    final icon = widget.isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;

    return RotationTransition(
      turns: widget.isDay ? _rotateController : const AlwaysStoppedAnimation(0),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.1),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: baseColor.withValues(alpha: 0.3),
                  size: widget.size * 1.2,
                ),
                Icon(
                  icon,
                  color: baseColor,
                  size: widget.size,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCloudy() {
    final baseColor = widget.color ?? Colors.white;
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 + (_floatController.value * 10)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.code == 1 || widget.code == 2) // Partly cloudy
                Positioned(
                  top: 0,
                  right: widget.size * 0.1,
                  child: RotationTransition(
                    turns: _rotateController,
                    child: Icon(
                      widget.isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                      color: widget.isDay ? Colors.amber : Colors.blueGrey.shade200,
                      size: widget.size * 0.6,
                    ),
                  ),
                ),
              Icon(
                Icons.cloud_rounded,
                color: baseColor.withValues(alpha: 0.9),
                size: widget.size,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRainy() {
    final baseColor = widget.color ?? Colors.blue.shade100;
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -3 + (_floatController.value * 6)),
              child: Icon(
                Icons.cloud_rounded,
                color: Colors.blueGrey.shade300,
                size: widget.size,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, (_pulseController.value * 15)),
                child: Opacity(
                  opacity: 1.0 - _pulseController.value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.water_drop_rounded, color: baseColor, size: widget.size * 0.3),
                      const SizedBox(width: 5),
                      Icon(Icons.water_drop_rounded, color: baseColor, size: widget.size * 0.3),
                      const SizedBox(width: 5),
                      Icon(Icons.water_drop_rounded, color: baseColor, size: widget.size * 0.3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSnowy() {
    final baseColor = widget.color ?? Colors.white;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.cloud_rounded,
              color: Colors.blueGrey.shade200,
              size: widget.size,
            ),
            Positioned(
              bottom: -widget.size * 0.1,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * pi,
                child: Transform.translate(
                  offset: Offset(0, _pulseController.value * 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ac_unit_rounded, color: baseColor, size: widget.size * 0.25),
                      const SizedBox(width: 8),
                      Icon(Icons.ac_unit_rounded, color: baseColor, size: widget.size * 0.35),
                      const SizedBox(width: 8),
                      Icon(Icons.ac_unit_rounded, color: baseColor, size: widget.size * 0.25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStormy() {
    final baseColor = widget.color ?? Colors.amberAccent;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Flash effect for thunder
        final isFlashing = _pulseController.value > 0.8;
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.cloud_rounded,
              color: isFlashing ? Colors.white : Colors.blueGrey.shade600,
              size: widget.size,
              shadows: [
                if (isFlashing)
                  const Shadow(color: Colors.amber, blurRadius: 30),
              ],
            ),
            Positioned(
              bottom: 0,
              child: Opacity(
                opacity: isFlashing ? 1.0 : 0.0,
                child: Icon(Icons.flash_on_rounded, color: baseColor, size: widget.size * 0.6),
              ),
            ),
          ],
        );
      },
    );
  }
}
