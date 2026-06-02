import 'package:data_gen_ai/core/enums/result_field.dart';
import 'package:flutter/material.dart';

class UtilityAIResultFieldDropdown extends StatelessWidget {
  const UtilityAIResultFieldDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: UtilityAIResultField.values
          .map(
            (f) => DropdownMenuItem<int>(
              value: f.value,
              child: Text(f.name),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
