import 'package:data_gen_ai/core/enums/consumable_type.dart';
import 'package:data_gen_ai/core/enums/shield_type.dart';
import 'package:data_gen_ai/core/enums/weapon_type.dart';
import 'package:data_gen_ai/models/item_category_definition.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:flutter/material.dart';

class ItemCategoryDefinitionEditor extends StatelessWidget {
  const ItemCategoryDefinitionEditor({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ItemCategoryDefinitionModel value;
  final ValueChanged<ItemCategoryDefinitionModel> onChanged;

  static const _categoryOptions = <int, String>{
    0: 'None',
    1: 'Consumable',
    2: 'Weapon',
    4: 'Shield',
  };

  @override
  Widget build(BuildContext context) {
    final showConsumable = (value.category & 1) != 0;
    final showWeapon = (value.category & 2) != 0;
    final showShield = (value.category & 4) != 0;

    return Column(
      children: <Widget>[
        EnumDropdown(
          label: 'Category flags',
          value: value.category,
          options: _categoryOptions,
          onChanged: (v) => onChanged(value.copyWith(category: v)),
        ),
        if (showConsumable)
          EnumDropdown(
            label: 'Consumable type',
            value: value.consumableTypeValue,
            options: {
              for (final e in ConsumableType.values) e.value: e.name,
            },
            onChanged: (v) => onChanged(value.copyWith(consumableTypeValue: v)),
          ),
        if (showWeapon)
          EnumDropdown(
            label: 'Weapon type',
            value: value.weaponTypeValue,
            options: {for (final e in WeaponType.values) e.value: e.name},
            onChanged: (v) => onChanged(value.copyWith(weaponTypeValue: v)),
          ),
        if (showShield)
          EnumDropdown(
            label: 'Shield type',
            value: value.shieldTypeValue,
            options: {for (final e in ShieldType.values) e.value: e.name},
            onChanged: (v) => onChanged(value.copyWith(shieldTypeValue: v)),
          ),
      ],
    );
  }
}
