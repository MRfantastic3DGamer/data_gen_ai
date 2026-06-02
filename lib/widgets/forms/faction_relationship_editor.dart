import 'package:data_gen_ai/core/enums/sensor_query_mode.dart';
import 'package:data_gen_ai/models/factions_config_model.dart';
import 'package:data_gen_ai/models/registry_option.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:flutter/material.dart';

class FactionRelationshipEditor extends StatelessWidget {
  const FactionRelationshipEditor({
    super.key,
    required this.relationship,
    required this.factionOptions,
    required this.onChanged,
    required this.onDelete,
  });

  final FactionRelationshipModel relationship;
  final List<RegistryOption<int>> factionOptions;
  final ValueChanged<FactionRelationshipModel> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: relationship.a,
                decoration: const InputDecoration(labelText: 'Faction A'),
                items: factionOptions
                    .map(
                      (o) => DropdownMenuItem<int>(
                        value: o.value,
                        child: Text(o.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(FactionRelationshipModel(a: v, b: relationship.b, type: relationship.type));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: relationship.b,
                decoration: const InputDecoration(labelText: 'Faction B'),
                items: factionOptions
                    .map(
                      (o) => DropdownMenuItem<int>(
                        value: o.value,
                        child: Text(o.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(FactionRelationshipModel(a: relationship.a, b: v, type: relationship.type));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EnumDropdown(
                label: 'Relationship',
                value: relationship.type,
                options: {
                  for (final e in FactionRelationshipType.values)
                    e.value: e.name,
                },
                onChanged: (v) => onChanged(
                  FactionRelationshipModel(
                    a: relationship.a,
                    b: relationship.b,
                    type: v,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
