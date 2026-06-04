import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/services/action_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/searchable_int_dropdown.dart';
import 'package:flutter/material.dart';

class ActionIdDropdown extends StatelessWidget {
  const ActionIdDropdown({
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
    final registryOptions = ActionCatalogService.actionOptions(context);
    final options = registryOptions
        .map(
          (o) => SearchableOption<int>(
            value: o.value,
            label: o.label,
            searchTerms: '${o.value}',
          ),
        )
        .toList();

    if (value >= 0 && !options.any((o) => o.value == value)) {
      options.add(
        SearchableOption<int>(
          value: value,
          label: 'Action_$value [$value]',
          searchTerms: '$value',
        ),
      );
      options.sort((a, b) => a.value.compareTo(b.value));
    }

    final effective = options.any((o) => o.value == value)
        ? value
        : (options.isNotEmpty ? options.first.value : -1);

    if (options.length <= 1) {
      return ListTile(
        title: Text(label),
        subtitle: const Text(
          'No action catalog entries found. Export ActionCatalogEntrySO '
          'assets from Unity or set action id manually.',
        ),
        trailing: SizedBox(
          width: 72,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(isDense: true),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null) onChanged(parsed);
            },
          ),
        ),
      );
    }

    return SearchableIntDropdown(
      label: label,
      value: effective,
      options: options,
      onChanged: onChanged,
    );
  }
}
