import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

/// NPK circular indicator — three circles showing N, P, K values.
class NpkIndicator extends StatelessWidget {
  final double? nAmount;
  final double? pAmount;
  final double? kAmount;

  const NpkIndicator({
    super.key,
    this.nAmount,
    this.pAmount,
    this.kAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _NpkCircle(
          symbol: 'N',
          label: 'نيتروجين',
          value: nAmount != null ? '${nAmount!.toStringAsFixed(0)} kg/ha' : '—',
          color: Colors.green,
          isDark: isDark,
        ),
        _NpkCircle(
          symbol: 'P',
          label: 'فسفور',
          value: pAmount != null ? '${pAmount!.toStringAsFixed(0)} kg/ha' : '—',
          color: Colors.purple,
          isDark: isDark,
        ),
        _NpkCircle(
          symbol: 'K',
          label: 'بوتاسيوم',
          value: kAmount != null ? '${kAmount!.toStringAsFixed(0)} kg/ha' : '—',
          color: Colors.orange,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _NpkCircle extends StatelessWidget {
  final String symbol;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _NpkCircle({
    required this.symbol,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.wp(16),
          height: context.wp(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: context.sp(22),
              ),
            ),
          ),
        ),
        SizedBox(height: context.hp(0.8)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: context.sp(12),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: context.sp(10),
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }
}
