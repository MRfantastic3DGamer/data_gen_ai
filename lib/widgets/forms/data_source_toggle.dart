import 'package:data_gen_ai/core/enums/data_source.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:flutter/material.dart';

class DataSourceToggle extends StatelessWidget {
  const DataSourceToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return EnumDropdown(
      label: label,
      value: value,
      options: {
        for (final e in DataSource.values) e.value: e.name,
      },
      onChanged: onChanged,
    );
  }
}
