import 'package:data_gen_ai/core/enums/consideration_mode.dart';
import 'package:data_gen_ai/core/enums/consideration_type.dart';
import 'package:data_gen_ai/widgets/forms/consideration_curve_preview.dart';
import 'package:data_gen_ai/widgets/forms/bool_toggle.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:data_gen_ai/widgets/forms/vector3_field.dart';
import 'package:flutter/material.dart';

class ConsiderationFunctionConfigEditor extends StatelessWidget {
  const ConsiderationFunctionConfigEditor({
    super.key,
    required this.config,
    required this.onChanged,
  });

  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onChanged;

  int _int(String key, [int fallback = 0]) => (config[key] ?? fallback) as int;

  double _dbl(String key, [double fallback = 0]) =>
      (config[key] ?? fallback).toDouble();

  bool _bool(String key, [bool fallback = false]) {
    final v = config[key];
    if (v is bool) return v;
    if (v is int) return v != 0;
    return fallback;
  }

  void _set(String key, Object value) {
    onChanged(<String, dynamic>{...config, key: value});
  }

  @override
  Widget build(BuildContext context) {
    final mode = _int('Mode');
    final type = _int('Type');
    final showVectorTarget = mode == ConsiderationMode.vectorDistance.value;

    return Column(
      children: <Widget>[
        ConsiderationCurvePreview(config: config),
        const SizedBox(height: 12),
        EnumDropdown(
          label: 'Mode',
          value: mode,
          options: {
            for (final e in ConsiderationMode.values) e.value: e.name,
          },
          onChanged: (v) => _set('Mode', v),
        ),
        EnumDropdown(
          label: 'Type',
          value: type,
          onChanged: (v) => _set('Type', v),
          options: {
            for (final e in ConsiderationType.values) e.value: e.name,
          },
        ),
        BoolToggle(
          label: 'Invert result',
          value: _bool('InvertResult'),
          onChanged: (v) => _set('InvertResult', v),
        ),
        if (showVectorTarget)
          Vector3Field(
            label: 'Target reference',
            value: Map<String, dynamic>.from(
              config['TargetReference'] as Map? ??
                  <String, dynamic>{'x': 0, 'y': 0, 'z': 0},
            ),
            onChanged: (v) => _set('TargetReference', v),
          ),
        FloatField(
          label: 'Slope',
          initialValue: _dbl('Slope', 1),
          onChanged: (v) => _set('Slope', v),
        ),
        FloatField(
          label: 'Offset X',
          initialValue: _dbl('OffsetX'),
          onChanged: (v) => _set('OffsetX', v),
        ),
        FloatField(
          label: 'Offset Y',
          initialValue: _dbl('OffsetY'),
          onChanged: (v) => _set('OffsetY', v),
        ),
        FloatField(
          label: 'Exponent',
          initialValue: _dbl('Exponent', 1),
          onChanged: (v) => _set('Exponent', v),
        ),
        FloatField(
          label: 'Threshold',
          initialValue: _dbl('Threshold', 0.5),
          onChanged: (v) => _set('Threshold', v),
        ),
        FloatField(
          label: 'Sigmoid steepness',
          initialValue: _dbl('SigmoidSteepness', 1),
          onChanged: (v) => _set('SigmoidSteepness', v),
        ),
        FloatField(
          label: 'Sigmoid midpoint',
          initialValue: _dbl('SigmoidMidpoint', 0.5),
          onChanged: (v) => _set('SigmoidMidpoint', v),
        ),
      ],
    );
  }
}
