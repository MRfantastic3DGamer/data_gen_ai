import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/searchable_int_dropdown.dart';
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
    final registryOptions = catalog.factionOptions(allowNone: allowNone);
    if (registryOptions.isEmpty) {
      return ListTile(
        title: Text(label),
        subtitle: const Text(
          'No FactionsConfig.json found. Export from Unity and reload.',
        ),
      );
    }

    final options = registryOptions
        .map(
          (o) => SearchableOption<int>(
            value: o.value,
            label: o.label,
            searchTerms: '${o.value}',
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
