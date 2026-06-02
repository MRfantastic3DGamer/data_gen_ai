import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/searchable_int_dropdown.dart';
import 'package:flutter/material.dart';

class AnimationTypeIdDropdown extends StatelessWidget {
  const AnimationTypeIdDropdown({
    super.key,
    required this.catalog,
    required this.value,
    required this.onChanged,
    this.label = 'Animation type',
    this.typesConfigGuid,
    this.factionId,
  });

  final RegistryCatalogService catalog;
  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final String? typesConfigGuid;
  final int? factionId;

  @override
  Widget build(BuildContext context) {
    final registryOptions = catalog.animationTypeOptions(
      typesConfigGuid: typesConfigGuid,
      factionId: factionId,
    );
    if (registryOptions.length <= 1) {
      return ListTile(
        title: Text(label),
        subtitle: const Text('No AnimationTypesConfig found for this faction.'),
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
