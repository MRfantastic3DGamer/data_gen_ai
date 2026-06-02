import 'package:data_gen_ai/core/enums/consumable_type.dart';
import 'package:data_gen_ai/core/enums/shield_type.dart';
import 'package:data_gen_ai/core/enums/weapon_type.dart';
import 'package:data_gen_ai/models/interaction_slot.dart';
import 'package:data_gen_ai/models/item_data.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/interaction_slot_row_editor.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';

class ItemDataEditorForm extends StatelessWidget {
  const ItemDataEditorForm({
    super.key,
    required this.data,
    required this.onChanged,
    this.idController,
    this.descriptionController,
  });

  final ItemDataModel data;
  final ValueChanged<ItemDataModel> onChanged;
  final TextEditingController? idController;
  final TextEditingController? descriptionController;

  static const _categoryOptions = <int, String>{
    0: 'None',
    1: 'Consumable',
    2: 'Weapon',
    4: 'Shield',
  };

  @override
  Widget build(BuildContext context) {
    final showConsumable = (data.category & 1) != 0;
    final showWeapon = (data.category & 2) != 0;
    final showShield = (data.category & 4) != 0;

    return Column(
      children: <Widget>[
        SectionCard(
          title: 'Identity',
          child: Column(
            children: <Widget>[
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Item ID'),
                onChanged: (v) => onChanged(data.copyWith(itemId: v)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (v) => onChanged(data.copyWith(description: v)),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Type',
          child: Column(
            children: <Widget>[
              EnumDropdown(
                label: 'Category',
                value: data.category,
                options: _categoryOptions,
                onChanged: (v) => onChanged(data.copyWith(category: v)),
              ),
              if (showConsumable)
                EnumDropdown(
                  label: 'Consumable type',
                  value: data.consumableTypeValue,
                  options: {
                    for (final e in ConsumableType.values) e.value: e.name,
                  },
                  onChanged: (v) =>
                      onChanged(data.copyWith(consumableTypeValue: v)),
                ),
              if (showWeapon)
                EnumDropdown(
                  label: 'Weapon type',
                  value: data.weaponTypeValue,
                  options: {
                    for (final e in WeaponType.values) e.value: e.name,
                  },
                  onChanged: (v) => onChanged(data.copyWith(weaponTypeValue: v)),
                ),
              if (showShield)
                EnumDropdown(
                  label: 'Shield type',
                  value: data.shieldTypeValue,
                  options: {
                    for (final e in ShieldType.values) e.value: e.name,
                  },
                  onChanged: (v) => onChanged(data.copyWith(shieldTypeValue: v)),
                ),
            ],
          ),
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
