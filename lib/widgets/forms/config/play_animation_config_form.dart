import 'package:data_gen_ai/models/play_animation_config.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/animation_type_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/raw_map_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayAnimationConfigForm extends StatelessWidget {
  const PlayAnimationConfigForm({
    super.key,
    required this.config,
    required this.onChanged,
    this.factionId,
  });

  final PlayAnimationConfigModel config;
  final ValueChanged<PlayAnimationConfigModel> onChanged;
  final int? factionId;

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<RegistryCatalogService>();
    final animId = (config.raw['Animation'] ?? 0) as int;

    return Column(
      children: <Widget>[
        AnimationTypeIdDropdown(
          catalog: catalog,
          label: 'Animation',
          value: animId,
          factionId: factionId,
          onChanged: (v) {
            final raw = Map<String, dynamic>.from(config.raw);
            raw['Animation'] = v;
            onChanged(PlayAnimationConfigModel(raw: raw));
          },
        ),
        RawMapConfigEditor(
          raw: config.raw,
          fields: const <RawMapFieldSpec>[
            RawMapFieldSpec(
              key: 'Loop',
              label: 'Loop',
              kind: RawMapFieldKind.boolField,
            ),
            RawMapFieldSpec(
              key: 'Duration',
              label: 'Duration',
              kind: RawMapFieldKind.floatField,
            ),
            RawMapFieldSpec(
              key: 'CompleteOnDuration',
              label: 'Complete on duration',
              kind: RawMapFieldKind.boolField,
            ),
            RawMapFieldSpec(
              key: 'LockMovement',
              label: 'Lock movement',
              kind: RawMapFieldKind.boolField,
            ),
          ],
          onChanged: (raw) => onChanged(PlayAnimationConfigModel(raw: raw)),
        ),
      ],
    );
  }
}
