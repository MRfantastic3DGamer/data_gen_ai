import 'package:data_gen_ai/models/actuator_mapping.dart';
import 'package:data_gen_ai/models/character_data.dart';
import 'package:data_gen_ai/models/interaction_slot.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/action_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/bool_toggle.dart';
import 'package:data_gen_ai/widgets/forms/character_stats_form.dart';
import 'package:data_gen_ai/widgets/forms/config/actuator_mapping_row_editor.dart';
import 'package:data_gen_ai/widgets/forms/config/eat_config_form.dart';
import 'package:data_gen_ai/widgets/forms/config/navigate_config_form.dart';
import 'package:data_gen_ai/widgets/forms/config/wait_config_form.dart';
import 'package:data_gen_ai/widgets/forms/faction_id_dropdown.dart';
import 'package:data_gen_ai/core/enums/character_types.dart';
import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/widgets/forms/searchable_int_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/interaction_slot_row_editor.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/asset_reference_list_editor.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterDataEditorForm extends StatelessWidget {
  const CharacterDataEditorForm({
    super.key,
    required this.data,
    required this.onChanged,
    this.descriptionController,
  });

  final CharacterDataModel data;
  final ValueChanged<CharacterDataModel> onChanged;
  final TextEditingController? descriptionController;

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<RegistryCatalogService>();
    return Column(
      children: <Widget>[
        SectionCard(
          title: 'Identity',
          child: TextField(
            controller: descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (v) => onChanged(data.copyWith(description: v)),
          ),
        ),
        SectionCard(
          title: 'Initial stats',
          child: CharacterStatsForm(
            stats: data.initialStats,
            onChanged: (s) => onChanged(data.copyWith(initialStats: s)),
          ),
        ),
        SectionCard(
          title: 'Core',
          child: Column(
            children: <Widget>[
              FactionIdDropdown(
                catalog: catalog,
                label: 'Faction',
                value: data.faction,
                onChanged: (v) => onChanged(data.copyWith(faction: v)),
              ),
              SearchableIntDropdown(
                label: 'Character type',
                value: data.characterType,
                options: CharacterTypes.values
                    .map(
                      (e) => SearchableOption<int>(
                        value: e.value,
                        label: e.name,
                      ),
                    )
                    .toList(),
                onChanged: (v) => onChanged(data.copyWith(characterType: v)),
              ),
              BoolToggle(
                label: 'Bake modular states',
                value: data.bakeModularStates,
                onChanged: (v) => onChanged(data.copyWith(bakeModularStates: v)),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'AI references',
          child: Column(
            children: <Widget>[
              AssetReferenceListEditor(
                label: 'Belief selections',
                typeKeys: const <String>['BeliefSelectionSO'],
                references: data.beliefsObjects,
                onChanged: (refs) =>
                    onChanged(data.copyWith(beliefsObjects: refs)),
              ),
              AssetReferenceListEditor(
                label: 'Actionables',
                typeKeys: const <String>['ActionableSO'],
                references: data.actionables,
                onChanged: (refs) => onChanged(data.copyWith(actionables: refs)),
              ),
              ActionIdDropdown(
                label: 'Default action',
                value: data.defaultAction,
                onChanged: (v) => onChanged(data.copyWith(defaultAction: v)),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Default configs',
          child: Column(
            children: <Widget>[
              NavigateConfigForm(
                config: data.defaultNavigateConfig,
                onChanged: (c) =>
                    onChanged(data.copyWith(defaultNavigateConfig: c)),
              ),
              WaitConfigForm(
                config: data.defaultWaitConfig,
                factionId: data.faction,
                onChanged: (c) => onChanged(data.copyWith(defaultWaitConfig: c)),
              ),
              EatConfigForm(
                config: data.defaultEatConfig,
                factionId: data.faction,
                onChanged: (c) => onChanged(data.copyWith(defaultEatConfig: c)),
              ),
            ],
          ),
        ),
        ListEditor(
          title: 'Actuator mappings',
          itemCount: data.actuatorMappings.length,
          onAdd: () => onChanged(
            data.copyWith(
              actuatorMappings: <ActuatorMappingModel>[
                ...data.actuatorMappings,
                const ActuatorMappingModel(),
              ],
            ),
          ),
          itemBuilder: (context, index) {
            return ActuatorMappingRowEditor(
              value: data.actuatorMappings[index],
              factionId: data.faction,
              onChanged: (row) {
                final list = List<ActuatorMappingModel>.from(
                  data.actuatorMappings,
                );
                list[index] = row;
                onChanged(data.copyWith(actuatorMappings: list));
              },
              onDelete: () {
                final list = List<ActuatorMappingModel>.from(
                  data.actuatorMappings,
                )..removeAt(index);
                onChanged(data.copyWith(actuatorMappings: list));
              },
            );
          },
        ),
        ListEditor(
          title: 'Interaction slots',
          itemCount: data.interactionSlots.length,
          onAdd: () => onChanged(
            data.copyWith(
              interactionSlots: <ItemInteractionSlotDefinition>[
                ...data.interactionSlots,
                const ItemInteractionSlotDefinition(),
              ],
            ),
          ),
          itemBuilder: (context, index) {
            return InteractionSlotRowEditor(
              value: data.interactionSlots[index],
              onChanged: (slot) {
                final list = List<ItemInteractionSlotDefinition>.from(
                  data.interactionSlots,
                );
                list[index] = slot;
                onChanged(data.copyWith(interactionSlots: list));
              },
              onDelete: () {
                final list = List<ItemInteractionSlotDefinition>.from(
                  data.interactionSlots,
                )..removeAt(index);
                onChanged(data.copyWith(interactionSlots: list));
              },
            );
          },
        ),
      ],
    );
  }
}
