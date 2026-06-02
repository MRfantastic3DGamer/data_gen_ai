import 'package:flutter/material.dart';

class Vector2Field extends StatelessWidget {
  const Vector2Field({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Map<String, dynamic> value;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                initialValue: '${value['x'] ?? 0}',
                decoration: const InputDecoration(labelText: 'X'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => onChanged(_copy(x: double.tryParse(v))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: '${value['y'] ?? 0}',
                decoration: const InputDecoration(labelText: 'Y'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => onChanged(_copy(y: double.tryParse(v))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, dynamic> _copy({double? x, double? y}) {
    return <String, dynamic>{
      'x': x ?? (value['x'] ?? 0),
      'y': y ?? (value['y'] ?? 0),
    };
  }
}
