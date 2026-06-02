import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/services/asset_index_service.dart';
import 'package:data_gen_ai/widgets/forms/searchable_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Unity asset reference picker — searchable list by display name (no manual GUID).
class AssetReferenceField extends StatelessWidget {
  const AssetReferenceField({
    super.key,
    required this.label,
    required this.reference,
    required this.onChanged,
    this.typeKeys,
    this.includeQueryViews = false,
    this.allowNone = true,
  });

  final String label;
  final UnityReference reference;
  final ValueChanged<UnityReference> onChanged;
  final List<String>? typeKeys;
  final bool includeQueryViews;
  final bool allowNone;

  @override
  Widget build(BuildContext context) {
    final index = context.read<AssetIndexService>();
    final options = index.optionsFor(
      typeKeys: typeKeys,
      includeQueryViews: includeQueryViews,
      allowNone: allowNone,
    );

    if (options.length <= 1 && !index.isBuilt) {
      return ListTile(
        title: Text(label),
        subtitle: const Text(
          'Load GameData JSON files to pick assets by name.',
        ),
      );
    }

    final current = index.optionForReference(reference) ??
        (reference.guid.isEmpty
            ? AssetPickerOption.empty
            : AssetPickerOption(
                guid: reference.guid,
                fileId: reference.fileId,
                label: 'Unknown asset',
                subtitle: reference.guid,
                typeKey: '',
              ));

    return InkWell(
      onTap: () async {
        final picked = await showAssetPickerSheet(
          context: context,
          title: label,
          options: options,
          selected: current.guid.isEmpty && current.label == '(None)'
              ? AssetPickerOption.empty
              : current,
        );
        if (picked == null) return;
        onChanged(index.resolveReference(reference, picked));
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: current.hasGuid
              ? null
              : current.path != null
              ? 'GUID not indexed — copy .meta files into RAW folder'
              : 'Tap to choose from loaded assets',
          suffixIcon: const Icon(Icons.search),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              current.label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (current.subtitle.isNotEmpty)
              Text(
                current.subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
