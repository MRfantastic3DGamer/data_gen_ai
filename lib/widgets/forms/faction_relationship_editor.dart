import 'package:data_gen_ai/core/enums/sensor_query_mode.dart';
import 'package:data_gen_ai/models/factions_config_model.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/faction_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/searchable_enum_dropdown.dart';
import 'package:flutter/material.dart';

class FactionRelationshipEditor extends StatelessWidget {
  const FactionRelationshipEditor({
    super.key,
    required this.relationship,
    required this.catalog,
    required this.onChanged,
    required this.onDelete,
  });

  final FactionRelationshipModel relationship;
  final RegistryCatalogService catalog;
  final ValueChanged<FactionRelationshipModel> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: FactionIdDropdown(
                catalog: catalog,
                label: 'Faction A',
                value: relationship.a,
                allowNone: false,
                onChanged: (v) => onChanged(
                  FactionRelationshipModel(a: v, b: relationship.b, type: relationship.type),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FactionIdDropdown(
                catalog: catalog,
                label: 'Faction B',
                value: relationship.b,
                allowNone: false,
                onChanged: (v) => onChanged(
                  FactionRelationshipModel(a: relationship.a, b: v, type: relationship.type),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SearchableEnumDropdown(
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
