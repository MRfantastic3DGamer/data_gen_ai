import 'package:data_gen_ai/core/enums/consumable_type.dart';
import 'package:data_gen_ai/core/enums/item_category.dart';
import 'package:data_gen_ai/core/enums/shield_type.dart';
import 'package:data_gen_ai/core/enums/weapon_type.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:flutter/material.dart';

/// Packed item type id (category in low 3 bits, subtype in upper bits) — matches Unity.
class ItemTypeIdPicker extends StatelessWidget {
  const ItemTypeIdPicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  int get _category => value & 0x7;
  int get _subtype => value >> 3;

  void _update({int? category, int? subtype}) {
    final cat = category ?? _category;
    final sub = subtype ?? _subtype;
    onChanged((sub << 3) | cat);
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        EnumDropdown(
          label: 'Category',
          value: category,
          options: const <int, String>{
            0: 'None',
            1: 'Consumable',
            2: 'Weapon',
            4: 'Shield',
          },
          onChanged: (v) => _update(category: v, subtype: 0),
        ),
        if (category == ItemCategory.consumable.value)
          EnumDropdown(
            label: 'Consumable type',
            value: _subtype,
            options: {
              for (final e in ConsumableType.values) e.value: e.name,
            },
            onChanged: (v) => _update(subtype: v),
          ),
        if (category == ItemCategory.weapon.value)
          EnumDropdown(
            label: 'Weapon type',
            value: _subtype,
            options: {for (final e in WeaponType.values) e.value: e.name},
            onChanged: (v) => _update(subtype: v),
          ),
        if (category == ItemCategory.shield.value)
          EnumDropdown(
            label: 'Shield type',
            value: _subtype,
            options: {for (final e in ShieldType.values) e.value: e.name},
            onChanged: (v) => _update(subtype: v),
          ),
      ],
    );
  }
}
