import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/forms/asset_reference_field.dart';
import 'package:flutter/material.dart';

/// @deprecated Use [AssetReferenceField] directly.
class ReferenceField extends StatelessWidget {
  const ReferenceField({
    super.key,
    required this.label,
    required this.reference,
    required this.onGuidChanged,
    this.typeKeys,
    this.includeQueryViews = false,
  });

  final String label;
  final UnityReference reference;
  final ValueChanged<String> onGuidChanged;
  final List<String>? typeKeys;
  final bool includeQueryViews;

  @override
  Widget build(BuildContext context) {
    return AssetReferenceField(
      label: label,
      reference: reference,
      typeKeys: typeKeys,
      includeQueryViews: includeQueryViews,
      onChanged: (ref) => onGuidChanged(ref.guid),
    );
  }
}
