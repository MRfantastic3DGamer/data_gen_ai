import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/utils/game_data_tree_builder.dart';
import 'package:data_gen_ai/widgets/common/game_data_folder_tree_view.dart';
import 'package:flutter/material.dart';

/// Modal sheet to search and pick one item from many options.
Future<T?> showSearchablePickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<SearchableOption<T>> options,
  T? selectedValue,
  String searchHint = 'Search by name…',
  bool useTreeView = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _SearchablePickerSheetBody<T>(
      title: title,
      options: options,
      selectedValue: selectedValue,
      searchHint: searchHint,
      useTreeView: useTreeView,
    ),
  );
}

Future<AssetPickerOption?> showAssetPickerSheet({
  required BuildContext context,
  required String title,
  required List<AssetPickerOption> options,
  AssetPickerOption? selected,
}) {
  final searchable = options
      .map(
        (o) => SearchableOption<AssetPickerOption>(
          value: o,
          label: o.label,
          subtitle: o.subtitle,
          searchTerms: '${o.typeKey} ${o.path ?? ''} ${o.guid}',
        ),
      )
      .toList();

  return showSearchablePickerSheet<AssetPickerOption>(
    context: context,
    title: title,
    options: searchable,
    selectedValue: selected,
    searchHint: 'Search assets by name, folder, or type…',
    useTreeView: true,
  );
}

class _SearchablePickerSheetBody<T> extends StatefulWidget {
  const _SearchablePickerSheetBody({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.searchHint,
    required this.useTreeView,
  });

  final String title;
  final List<SearchableOption<T>> options;
  final T? selectedValue;
  final String searchHint;
  final bool useTreeView;

  @override
  State<_SearchablePickerSheetBody<T>> createState() =>
      _SearchablePickerSheetBodyState<T>();
}

class _SearchablePickerSheetBodyState<T>
    extends State<_SearchablePickerSheetBody<T>> {
  String _query = '';

  List<SearchableOption<T>> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.searchableText.contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SearchBar(
                hintText: widget.searchHint,
                leading: const Icon(Icons.search),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('No matches'))
                  : widget.useTreeView &&
                        _filtered.isNotEmpty &&
                        _filtered.first.value is AssetPickerOption
                  ? _buildAssetTree(context)
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final opt = _filtered[index];
                        final selected = opt.value == widget.selectedValue;
                        return ListTile(
                          title: Text(opt.label),
                          subtitle: opt.subtitle.isEmpty
                              ? null
                              : Text(opt.subtitle),
                          selected: selected,
                          trailing: selected
                              ? const Icon(Icons.check_circle_outline)
                              : null,
                          onTap: () => Navigator.pop(context, opt.value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTree(BuildContext context) {
    final assetOptions = _filtered
        .map((o) => o.value as AssetPickerOption)
        .toList();
    final roots = GameDataTreeBuilder.fromAssetOptions(assetOptions);

    return GameDataFolderTreeView(
      roots: roots,
      initiallyExpandAll: _query.isNotEmpty,
      bottomPadding: 16,
      onFileTap: (node) {
        final option = node.option;
        if (option != null) {
          Navigator.pop(context, option as T);
        }
      },
      fileBuilder: (ctx, node) {
        final option = node.option;
        if (option == null) return const SizedBox.shrink();
        final selected = option == widget.selectedValue;
        return ListTile(
          leading: Icon(
            selected ? Icons.check_circle : Icons.description_outlined,
            color: selected
                ? Theme.of(ctx).colorScheme.primary
                : Theme.of(ctx).colorScheme.onSurfaceVariant,
          ),
          title: Text(option.label),
          subtitle: option.subtitle.isEmpty ? null : Text(option.subtitle),
          selected: selected,
          onTap: () => Navigator.pop(context, option as T),
        );
      },
    );
  }
}
