import 'package:data_gen_ai/models/combo_data_so.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:flutter/material.dart';

class ComboStateGridEditor extends StatelessWidget {
  const ComboStateGridEditor({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final ComboStateModel state;
  final ValueChanged<ComboStateModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final slots = List<int>.from(state.slots);
    while (slots.length < 12) {
      slots.add(0);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(12, (index) {
        return SizedBox(
          width: 100,
          child: IntField(
            label: 'Slot $index',
            initialValue: slots[index],
            onChanged: (v) {
              final next = List<int>.from(slots);
              next[index] = v;
              onChanged(ComboStateModel(slots: next));
            },
          ),
        );
      }),
    );
  }
}
