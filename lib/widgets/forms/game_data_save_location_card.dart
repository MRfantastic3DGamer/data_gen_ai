import 'package:data_gen_ai/core/theme/form_spacing.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';

/// Folder path + file name fields used when creating a new JSON asset.
class GameDataSaveLocationCard extends StatelessWidget {
  const GameDataSaveLocationCard({
    super.key,
    required this.folderController,
    required this.fileNameController,
    this.readOnly = false,
    this.helperText,
  });

  final TextEditingController folderController;
  final TextEditingController fileNameController;
  final bool readOnly;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Save location',
      subtitle: helperText ?? 'Relative to your local RAW folder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: FormSpacing.fieldPadding,
            child: TextField(
              controller: folderController,
              readOnly: readOnly,
              decoration: const InputDecoration(
                labelText: 'Folder path',
                hintText: 'e.g. beliefs, queries, Animations',
              ),
              textCapitalization: TextCapitalization.none,
            ),
          ),
          Padding(
            padding: FormSpacing.fieldPadding,
            child: TextField(
              controller: fileNameController,
              readOnly: readOnly,
              decoration: const InputDecoration(
                labelText: 'File name',
                hintText: 'e.g. my_belief (saved as .json)',
              ),
              textCapitalization: TextCapitalization.none,
            ),
          ),
        ],
      ),
    );
  }
}
