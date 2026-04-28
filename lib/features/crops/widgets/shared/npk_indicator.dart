import 'package:flutter/material.dart';

/// NPK layout — simple text-based data row.
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NpkItem(
          symbol: 'N',
          label: 'نيتروجين',
          value: nAmount != null ? '${nAmount!.toStringAsFixed(0)} kg/ha' : '—',
        ),
        _NpkItem(
          symbol: 'P',
          label: 'فسفور',
          value: pAmount != null ? '${pAmount!.toStringAsFixed(0)} kg/ha' : '—',
        ),
        _NpkItem(
          symbol: 'K',
          label: 'بوتاسيوم',
          value: kAmount != null ? '${kAmount!.toStringAsFixed(0)} kg/ha' : '—',
        ),
      ],
    );
  }
}

class _NpkItem extends StatelessWidget {
  final String symbol;
  final String label;
  final String value;

  const _NpkItem({
    required this.symbol,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
