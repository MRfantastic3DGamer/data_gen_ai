import 'package:data_gen_ai/models/considerable_so.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:data_gen_ai/widgets/forms/asset_reference_field.dart';
import 'package:data_gen_ai/widgets/forms/utility_ai_result_field_dropdown.dart';
import 'package:flutter/material.dart';

class ConsiderableConfigEditor extends StatelessWidget {
  const ConsiderableConfigEditor({
    super.key,
    required this.config,
    required this.onChanged,
  });

  final ConsiderableConfigModel config;
  final ValueChanged<ConsiderableConfigModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FloatField(
          label: 'Default value',
          initialValue: config.defaultValue,
          onChanged: (v) => onChanged(
            ConsiderableConfigModel(
              defaultValue: v,
              minValue: config.minValue,
              maxValue: config.maxValue,
              queryInput: config.queryInput,
              field: config.field,
            ),
          ),
        ),
        AssetReferenceField(
          label: 'Query input',
          reference: config.queryInput,
          includeQueryViews: true,
          onChanged: (ref) => onChanged(
            ConsiderableConfigModel(
              defaultValue: config.defaultValue,
              minValue: config.minValue,
              maxValue: config.maxValue,
              queryInput: ref,
              field: config.field,
            ),
          ),
        ),
        UtilityAIResultFieldDropdown(
          label: 'Result field',
          value: config.field,
          onChanged: (v) => onChanged(
            ConsiderableConfigModel(
              defaultValue: config.defaultValue,
              minValue: config.minValue,
              maxValue: config.maxValue,
              queryInput: config.queryInput,
              field: v,
            ),
          ),
        ),
      ],
    );
  }
}
