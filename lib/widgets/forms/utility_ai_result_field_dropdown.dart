import 'package:data_gen_ai/core/enums/result_field.dart';
import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/widgets/forms/searchable_int_dropdown.dart';
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
    final options = UtilityAIResultField.values
        .map(
          (f) => SearchableOption<int>(
            value: f.value,
            label: f.name,
            searchTerms: '${f.value}',
          ),
        )
        .toList();

    return SearchableIntDropdown(
      label: label,
      value: value,
      options: options,
      onChanged: onChanged,
    );
  }
}
