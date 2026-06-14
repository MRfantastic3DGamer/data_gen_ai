import 'package:data_gen_ai/core/theme/form_spacing.dart';
import 'package:flutter/material.dart';

class StringDropdownField extends StatelessWidget {
  const StringDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: FormSpacing.fieldPadding,
      child: DropdownButtonFormField<String>(
        value: options.contains(value) ? value : options.first,
        decoration: InputDecoration(labelText: label),
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              ),
            )
            .toList(),
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
      ),
    );
  }
}
