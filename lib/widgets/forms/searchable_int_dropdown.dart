import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/widgets/forms/searchable_picker_sheet.dart';
import 'package:flutter/material.dart';

/// Searchable picker for numeric registry options (factions, animation types, actions).
class SearchableIntDropdown extends StatelessWidget {
  const SearchableIntDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
  });

  final String label;
  final int value;
  final List<SearchableOption<int>> options;
  final ValueChanged<int> onChanged;
  final String? helperText;

  SearchableOption<int>? get _selected {
    for (final o in options) {
      if (o.value == value) return o;
    }
    return options.isNotEmpty ? options.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return InkWell(
      onTap: () async {
        final picked = await showSearchablePickerSheet<int>(
          context: context,
          title: label,
          options: options,
          selectedValue: value,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selected?.label ?? 'Select…',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
