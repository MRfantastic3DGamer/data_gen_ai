import 'package:data_gen_ai/models/nav_config.dart';
import 'package:data_gen_ai/widgets/forms/raw_map_config_editor.dart';
import 'package:flutter/material.dart';

class NavigateConfigForm extends StatelessWidget {
  const NavigateConfigForm({
    super.key,
    required this.config,
    required this.onChanged,
  });

  final NavigateConfigModel config;
  final ValueChanged<NavigateConfigModel> onChanged;

  static const _fields = <RawMapFieldSpec>[
    RawMapFieldSpec(
      key: 'StoppingDistance',
      label: 'Stopping distance',
      kind: RawMapFieldKind.floatField,
      defaultValue: 0.5,
    ),
    RawMapFieldSpec(
      key: 'TrackMovingTarget',
      label: 'Track moving target',
      kind: RawMapFieldKind.boolField,
    ),
    RawMapFieldSpec(
      key: 'DestinationUpdateInterval',
      label: 'Destination update interval',
      kind: RawMapFieldKind.floatField,
      defaultValue: 0.25,
    ),
    RawMapFieldSpec(
      key: 'CompleteOnArrival',
      label: 'Complete on arrival',
      kind: RawMapFieldKind.boolField,
      defaultValue: true,
    ),
    RawMapFieldSpec(
      key: 'SpeedMultiplier',
      label: 'Speed multiplier',
      kind: RawMapFieldKind.floatField,
      defaultValue: 1,
    ),
    RawMapFieldSpec(
      key: 'UseDirectMovementInput',
      label: 'Use direct movement input',
      kind: RawMapFieldKind.boolField,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RawMapConfigEditor(
      raw: config.raw,
      fields: _fields,
      onChanged: (raw) => onChanged(NavigateConfigModel(raw: raw)),
    );
  }
}
