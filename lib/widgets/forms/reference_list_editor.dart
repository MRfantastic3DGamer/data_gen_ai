import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/forms/reference_field.dart';
import 'package:flutter/material.dart';

class ReferenceListEditor extends StatelessWidget {
  const ReferenceListEditor({
    super.key,
    required this.references,
    required this.label,
    required this.onChanged,
  });

  final List<UnityReference> references;
  final String label;
  final ValueChanged<List<UnityReference>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var i = 0; i < references.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ReferenceField(
                  label: '$label #${i + 1}',
                  reference: references[i],
                  onGuidChanged: (guid) {
                    final next = List<UnityReference>.from(references);
                    next[i] = UnityReference(
                      guid: guid,
                      fileId: guid.isEmpty ? 0 : 11400000,
                      type: 2,
                    );
                    onChanged(next);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  final next = List<UnityReference>.from(references)..removeAt(i);
                  onChanged(next);
                },
              ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              onChanged(
                <UnityReference>[
                  ...references,
                  UnityReference.empty(),
                ],
              );
            },
            icon: const Icon(Icons.add),
            label: Text('Add $label'),
          ),
        ),
      ],
    );
  }
}
