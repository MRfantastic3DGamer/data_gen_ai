import 'package:data_gen_ai/models/registry_option.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter/material.dart';

class AnimationTypeIdDropdown extends StatelessWidget {
  const AnimationTypeIdDropdown({
    super.key,
    required this.catalog,
    required this.value,
    required this.onChanged,
    this.label = 'Animation type',
    this.factionId,
    this.typesConfigGuid,
  });

  final RegistryCatalogService catalog;
  final int value;
  final ValueChanged<int> onChanged;
  final String label;
  final int? factionId;
  final String? typesConfigGuid;

  @override
  Widget build(BuildContext context) {
    final options = catalog.animationTypeOptions(
      factionId: factionId,
      typesConfigGuid: typesConfigGuid,
    );
    if (options.length <= 1) {
      return ListTile(
        title: Text(label),
        subtitle: Text(
          factionId != null
              ? 'No Animation Types config for faction ${catalog.factionLabel(factionId!)}.'
              : 'No Animation Types config JSON found.',
        ),
      );
    }

    final selected = options.any((o) => o.value == value)
        ? value
        : options.first.value;

    return DropdownButtonFormField<int>(
      value: selected,
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
}
