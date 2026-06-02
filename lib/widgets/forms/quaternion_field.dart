import 'package:flutter/material.dart';

class QuaternionField extends StatelessWidget {
  const QuaternionField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Map<String, dynamic> value;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[_cell('x'), _cell('y'), _cell('z'), _cell('w')],
        ),
      ],
    );
  }

  Widget _cell(String key) {
    return SizedBox(
      width: 90,
      child: TextFormField(
        initialValue: (value[key] ?? 0).toString(),
        decoration: InputDecoration(labelText: key),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (raw) => onChanged(<String, dynamic>{
          ...value,
          key: double.tryParse(raw) ?? 0,
        }),
      ),
    );
  }
}
