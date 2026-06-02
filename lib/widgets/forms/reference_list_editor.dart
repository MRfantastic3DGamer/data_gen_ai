import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/forms/asset_reference_list_editor.dart';
import 'package:flutter/material.dart';

/// @deprecated Use [AssetReferenceListEditor] directly.
class ReferenceListEditor extends StatelessWidget {
  const ReferenceListEditor({
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
    return AssetReferenceListEditor(
      references: references,
      label: label,
      typeKeys: typeKeys,
      includeQueryViews: includeQueryViews,
      onChanged: onChanged,
    );
  }
}
