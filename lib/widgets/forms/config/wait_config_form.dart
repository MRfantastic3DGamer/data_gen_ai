import 'package:data_gen_ai/models/wait_config.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/animation_type_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/raw_map_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaitConfigForm extends StatelessWidget {
  const WaitConfigForm({
    super.key,
    required this.config,
    required this.onChanged,
    this.factionId,
  });

  final WaitConfigModel config;
  final ValueChanged<WaitConfigModel> onChanged;
  final int? factionId;

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<RegistryCatalogService>();
    final animId = (config.raw['waitAnimation'] ?? 0) as int;

    return Column(
      children: <Widget>[
        RawMapConfigEditor(
          raw: config.raw,
          fields: const <RawMapFieldSpec>[
            RawMapFieldSpec(
              key: 'Duration',
              label: 'Duration',
              kind: RawMapFieldKind.floatField,
            ),
            RawMapFieldSpec(
              key: 'StopNavigation',
              label: 'Stop navigation',
              kind: RawMapFieldKind.boolField,
              defaultValue: true,
            ),
          ],
          onChanged: (raw) => onChanged(WaitConfigModel(raw: raw)),
        ),
        AnimationTypeIdDropdown(
          catalog: catalog,
          label: 'Wait animation',
          value: animId,
          factionId: factionId,
          onChanged: (v) {
            final raw = Map<String, dynamic>.from(config.raw);
            raw['waitAnimation'] = v;
            onChanged(WaitConfigModel(raw: raw));
          },
        ),
      ],
    );
  }
}
