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
      children: [
        Expanded(
          child: _NpkItem(
            symbol: 'N',
            label: 'نيتروجين',
            value: nAmount != null ? nAmount!.toStringAsFixed(0) : '—',
            color: Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NpkItem(
            symbol: 'P',
            label: 'فسفور',
            value: pAmount != null ? pAmount!.toStringAsFixed(0) : '—',
            color: Colors.orange.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NpkItem(
            symbol: 'K',
            label: 'بوتاسيوم',
            value: kAmount != null ? kAmount!.toStringAsFixed(0) : '—',
            color: Colors.purple.shade600,
          ),
        ),
      ],
    );
  }
}

class _NpkItem extends StatelessWidget {
  final String symbol;
  final String label;
  final String value;
  final Color color;

  const _NpkItem({
    required this.symbol,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              symbol,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            'كجم/هكتار',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
