import 'package:data_gen_ai/core/enums/interaction_type.dart';
import 'package:data_gen_ai/models/reserve_slot_config.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:flutter/material.dart';

class ReserveSlotConfigForm extends StatelessWidget {
  const ReserveSlotConfigForm({
    super.key,
    required this.config,
    required this.onChanged,
  });

  final ReserveSlotConfigModel config;
  final ValueChanged<ReserveSlotConfigModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final filter = (config.raw['Filter'] ?? config.raw['filter'] ?? 0) as int;
    return EnumDropdown(
      label: 'Filter (interaction type)',
      value: filter,
      options: {for (final e in InteractionType.values) e.value: e.name},
      onChanged: (v) {
        final raw = Map<String, dynamic>.from(config.raw);
        raw['Filter'] = v;
        onChanged(ReserveSlotConfigModel(raw: raw));
      },
    );
  }
}
