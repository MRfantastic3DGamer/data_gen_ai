import 'package:data_gen_ai/models/registry_option.dart';
import 'package:data_gen_ai/services/action_catalog_service.dart';
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
    final options = ActionCatalogService.actionOptions(context);
    final effective = options.any((o) => o.value == value)
        ? value
        : (options.isNotEmpty ? options.first.value : -1);

    return DropdownButtonFormField<int>(
      initialValue: effective,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: options
          .map(
            (RegistryOption<int> o) => DropdownMenuItem<int>(
              value: o.value,
              child: Text(o.label),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
