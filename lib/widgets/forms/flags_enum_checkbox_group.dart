import 'package:flutter/material.dart';

class FlagsEnumCheckboxGroup extends StatelessWidget {
  const FlagsEnumCheckboxGroup({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final int value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 0,
          children: options.entries.map((entry) {
            final selected = (value & entry.key) != 0;
            return FilterChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (on) {
                var next = value;
                if (on) {
                  next |= entry.key;
                } else {
                  next &= ~entry.key;
                }
                onChanged(next);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
