import 'package:data_gen_ai/models/registry_option.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter/material.dart';

class FactionIdDropdown extends StatelessWidget {
  const FactionIdDropdown({
    super.key,
    required this.catalog,
    required this.value,
    required this.onChanged,
    this.label = 'Faction',
    this.allowNone = true,
  });

  final RegistryCatalogService catalog;
  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final bool allowNone;

  @override
  Widget build(BuildContext context) {
    final options = catalog.factionOptions(allowNone: allowNone);
    if (options.isEmpty) {
      return ListTile(
        title: Text(label),
        subtitle: const Text(
          'No FactionsConfig.json found. Export from Unity and reload.',
        ),
      );
    }

    final selected = _matchOption(options, value);
    return DropdownButtonFormField<int>(
      value: selected?.value,
      decoration: InputDecoration(labelText: label),
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

  RegistryOption<int>? _matchOption(List<RegistryOption<int>> options, int v) {
    for (final o in options) {
      if (o.value == v) return o;
    }
    return options.isNotEmpty ? options.first : null;
  }
}
