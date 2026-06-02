import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:flutter/material.dart';

class ReferenceField extends StatelessWidget {
  const ReferenceField({
    super.key,
    required this.label,
    required this.reference,
    required this.onGuidChanged,
  });

  final String label;
  final UnityReference reference;
  final ValueChanged<String> onGuidChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: reference.guid,
      decoration: InputDecoration(
        labelText: '$label GUID',
        helperText: 'fileID: ${reference.fileId}',
      ),
      onChanged: onGuidChanged,
    );
  }
}
