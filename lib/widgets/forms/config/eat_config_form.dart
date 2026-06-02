import 'package:data_gen_ai/models/eat_config.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/animation_type_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/raw_map_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EatConfigForm extends StatelessWidget {
  const EatConfigForm({
    super.key,
    required this.config,
    required this.onChanged,
    this.factionId,
  });

  final EatConfigModel config;
  final ValueChanged<EatConfigModel> onChanged;
  final int? factionId;

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<RegistryCatalogService>();
    final animId = (config.raw['Animation'] ?? config.raw['animation'] ?? 0)
        as int;

    return Column(
      children: <Widget>[
        RawMapConfigEditor(
          raw: config.raw,
          fields: const <RawMapFieldSpec>[
            RawMapFieldSpec(
              key: 'SatietyIncreasePerSecond',
              label: 'Satiety increase / sec',
              kind: RawMapFieldKind.floatField,
            ),
          ],
          onChanged: (raw) => onChanged(EatConfigModel(raw: raw)),
        ),
        AnimationTypeIdDropdown(
          catalog: catalog,
          label: 'Animation',
          value: animId,
          factionId: factionId,
          onChanged: (v) {
            final raw = Map<String, dynamic>.from(config.raw);
            raw['Animation'] = v;
            onChanged(EatConfigModel(raw: raw));
          },
        ),
      ],
    );
  }
}
