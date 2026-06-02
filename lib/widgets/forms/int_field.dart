import 'package:flutter/material.dart';

class IntField extends StatelessWidget {
  const IntField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final int initialValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue.toString(),
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (raw) => onChanged(int.tryParse(raw) ?? 0),
    );
  }
}
