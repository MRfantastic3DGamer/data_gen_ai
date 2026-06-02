import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
  });

  final String label;
  final double value;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label ${value.toStringAsFixed(1)} / ${safeMax.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: (value / safeMax).clamp(0.0, 1.0)),
      ],
    );
  }
}
