import 'package:data_gen_ai/widgets/forms/bool_toggle.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:flutter/material.dart';

enum RawMapFieldKind { intField, floatField, boolField, stringField }

class RawMapFieldSpec {
  const RawMapFieldSpec({
    required this.key,
    required this.label,
    required this.kind,
    this.defaultValue,
  });

  final String key;
  final String label;
  final RawMapFieldKind kind;
  final Object? defaultValue;
}

class RawMapConfigEditor extends StatelessWidget {
  const RawMapConfigEditor({
    super.key,
    required this.raw,
    required this.fields,
    required this.onChanged,
  });

  final Map<String, dynamic> raw;
  final List<RawMapFieldSpec> fields;
  final ValueChanged<Map<String, dynamic>> onChanged;

  Map<String, dynamic> _update(String key, Object? value) {
    final next = Map<String, dynamic>.from(raw);
    if (value == null) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    onChanged(next);
    return next;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: fields.map((spec) {
        switch (spec.kind) {
          case RawMapFieldKind.intField:
            return IntField(
              label: spec.label,
              initialValue: (raw[spec.key] ?? spec.defaultValue ?? 0) as int,
              onChanged: (v) => _update(spec.key, v),
            );
          case RawMapFieldKind.floatField:
            return FloatField(
              label: spec.label,
              initialValue: (raw[spec.key] ?? spec.defaultValue ?? 0.0)
                  .toDouble(),
              onChanged: (v) => _update(spec.key, v),
            );
          case RawMapFieldKind.boolField:
            return BoolToggle(
              label: spec.label,
              value: (raw[spec.key] ?? spec.defaultValue ?? false) as bool,
              onChanged: (v) => _update(spec.key, v),
            );
          case RawMapFieldKind.stringField:
            return TextFormField(
              initialValue: '${raw[spec.key] ?? spec.defaultValue ?? ''}',
              decoration: InputDecoration(labelText: spec.label),
              onChanged: (v) => _update(spec.key, v),
            );
        }
      }).toList(),
    );
  }
}
