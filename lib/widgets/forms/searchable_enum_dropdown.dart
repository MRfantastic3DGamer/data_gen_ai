import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/widgets/forms/searchable_int_dropdown.dart';
import 'package:flutter/material.dart';

/// Searchable version of [EnumDropdown] for long enum lists.
class SearchableEnumDropdown extends StatelessWidget {
  const SearchableEnumDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final int value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final searchable = options.entries
        .map(
          (e) => SearchableOption<int>(
            value: e.key,
            label: e.value,
            searchTerms: '${e.key}',
          ),
        )
        .toList();

    return SearchableIntDropdown(
      label: label,
      value: value,
      options: searchable,
      onChanged: onChanged,
    );
  }
}
