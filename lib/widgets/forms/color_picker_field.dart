import 'package:flutter/material.dart';

class ColorPickerField extends StatelessWidget {
  const ColorPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Map<String, dynamic> value;
  final ValueChanged<Map<String, dynamic>> onChanged;

  Color get _color {
    int ch(Object? v, [double fallback = 0]) =>
        (((v ?? fallback) as num) * 255).round().clamp(0, 255);
    return Color.fromARGB(
      ch(value['a'], 1),
      ch(value['r'], 0.5),
      ch(value['g'], 0.5),
      ch(value['b'], 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _color,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onTap: () async {
        final picked = await showDialog<Color>(
          context: context,
          builder: (ctx) => _SimpleColorDialog(initial: _color),
        );
        if (picked != null) {
          onChanged(<String, dynamic>{
            'r': picked.r / 255,
            'g': picked.g / 255,
            'b': picked.b / 255,
            'a': picked.a / 255,
          });
        }
      },
    );
  }
}

class _SimpleColorDialog extends StatefulWidget {
  const _SimpleColorDialog({required this.initial});
  final Color initial;

  @override
  State<_SimpleColorDialog> createState() => _SimpleColorDialogState();
}

class _SimpleColorDialogState extends State<_SimpleColorDialog> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.initial;
  }

  static const _presets = <Color>[
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick color'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _presets.map((c) {
          return InkWell(
            onTap: () => setState(() => _color = c),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c,
                border: Border.all(
                  color: _color == c ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _color),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
