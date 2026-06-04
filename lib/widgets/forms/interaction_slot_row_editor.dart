import 'package:data_gen_ai/core/enums/interaction_type.dart';
import 'package:data_gen_ai/core/enums/termination_authority.dart';
import 'package:data_gen_ai/models/interaction_slot.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/quaternion_field.dart';
import 'package:data_gen_ai/widgets/forms/vector3_field.dart';
import 'package:flutter/material.dart';
import 'package:data_gen_ai/core/theme/editor_preferences_scope.dart';

class InteractionSlotRowEditor extends StatelessWidget {
  const InteractionSlotRowEditor({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onDelete,
  });

  final ItemInteractionSlotDefinition value;
  final ValueChanged<ItemInteractionSlotDefinition> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(context.editorFieldGap * 0.65),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Slot (${InteractionType.values.firstWhere((e) => e.value == value.interactionType, orElse: () => InteractionType.none).name})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
            EnumDropdown(
              label: 'Interaction type',
              value: value.interactionType,
              options: {
                for (final e in InteractionType.values) e.value: e.name,
              },
              onChanged: (v) => onChanged(
                ItemInteractionSlotDefinition(
                  interactionType: v,
                  terminationAuthority: value.terminationAuthority,
                  localPosition: value.localPosition,
                  localRotation: value.localRotation,
                ),
              ),
            ),
            EnumDropdown(
              label: 'Termination authority',
              value: value.terminationAuthority,
              options: {
                for (final e in TerminationAuthority.values) e.value: e.name,
              },
              onChanged: (v) => onChanged(
                ItemInteractionSlotDefinition(
                  interactionType: value.interactionType,
                  terminationAuthority: v,
                  localPosition: value.localPosition,
                  localRotation: value.localRotation,
                ),
              ),
            ),
            Vector3Field(
              label: 'Local position',
              value: value.localPosition.toJson(),
              onChanged: (m) => onChanged(
                ItemInteractionSlotDefinition(
                  interactionType: value.interactionType,
                  terminationAuthority: value.terminationAuthority,
                  localPosition: Vector3Data.fromJson(m),
                  localRotation: value.localRotation,
                ),
              ),
            ),
            QuaternionField(
              label: 'Local rotation',
              value: value.localRotation.toJson(),
              onChanged: (m) => onChanged(
                ItemInteractionSlotDefinition(
                  interactionType: value.interactionType,
                  terminationAuthority: value.terminationAuthority,
                  localPosition: value.localPosition,
                  localRotation: QuaternionData.fromJson(m),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
