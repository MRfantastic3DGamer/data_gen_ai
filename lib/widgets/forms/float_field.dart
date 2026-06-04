import 'package:data_gen_ai/core/theme/form_spacing.dart';
import 'package:flutter/material.dart';

class FloatField extends StatelessWidget {
  const FloatField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FormSpacing.fieldPadding,
      child: TextFormField(
        initialValue: initialValue.toString(),
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (raw) => onChanged(double.tryParse(raw) ?? 0),
      ),
    );
  }
}
