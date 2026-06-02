import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/forms/asset_reference_field.dart';
import 'package:flutter/material.dart';

class AssetReferenceListEditor extends StatelessWidget {
  const AssetReferenceListEditor({
    super.key,
    required this.references,
    required this.label,
    required this.onChanged,
    this.typeKeys,
    this.includeQueryViews = false,
  });

  final List<UnityReference> references;
  final String label;
  final ValueChanged<List<UnityReference>> onChanged;
  final List<String>? typeKeys;
  final bool includeQueryViews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (references.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('No items'),
          ),
        for (var i = 0; i < references.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AssetReferenceField(
                  label: '$label #${i + 1}',
                  reference: references[i],
                  typeKeys: typeKeys,
                  includeQueryViews: includeQueryViews,
                  onChanged: (ref) {
                    final next = List<UnityReference>.from(references);
                    next[i] = ref;
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
                <UnityReference>[...references, UnityReference.empty()],
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
