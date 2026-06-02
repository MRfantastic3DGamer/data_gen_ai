import 'package:flutter/material.dart';

class Vector3Field extends StatelessWidget {
  const Vector3Field({
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
        Row(
          children: <Widget>[
            _cell('x'),
            const SizedBox(width: 8),
            _cell('y'),
            const SizedBox(width: 8),
            _cell('z'),
          ],
        ),
      ],
    );
  }

  Widget _cell(String key) {
    return Expanded(
      child: TextFormField(
        initialValue: (value[key] ?? 0).toString(),
        decoration: InputDecoration(labelText: key),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (raw) {
          onChanged(<String, dynamic>{
            ...value,
            key: double.tryParse(raw) ?? 0,
          });
        },
      ),
    );
  }
}
