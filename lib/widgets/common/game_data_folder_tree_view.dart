import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/models/game_data_tree_node.dart';
import 'package:flutter/material.dart';

typedef GameDataTreeFileTap = void Function(GameDataTreeNode node);

/// Expandable folder tree for GameData JSON paths.
class GameDataFolderTreeView extends StatefulWidget {
  const GameDataFolderTreeView({
    super.key,
    required this.roots,
    required this.onFileTap,
    this.fileBuilder,
    this.emptyMessage = 'No items',
    this.initiallyExpandAll = false,
    this.bottomPadding = 88,
  });

  final List<GameDataTreeNode> roots;
  final GameDataTreeFileTap onFileTap;
  final Widget Function(BuildContext context, GameDataTreeNode node)? fileBuilder;
  final String emptyMessage;
  final bool initiallyExpandAll;
  final double bottomPadding;

  @override
  State<GameDataFolderTreeView> createState() =>
      _GameDataFolderTreeViewState();
}

class _GameDataFolderTreeViewState extends State<GameDataFolderTreeView> {
  final Set<String> _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    if (widget.initiallyExpandAll) {
      _expandAll(widget.roots, '');
    }
  }

  @override
  void didUpdateWidget(covariant GameDataFolderTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpandAll && oldWidget.roots != widget.roots) {
      _expanded.clear();
      _expandAll(widget.roots, '');
    }
  }

  void _expandAll(List<GameDataTreeNode> nodes, String prefix) {
    for (final node in nodes) {
      if (node.isFolder) {
        final key = prefix.isEmpty ? node.name : '$prefix/${node.name}';
        _expanded.add(key);
        _expandAll(node.children, key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.roots.isEmpty) {
      return Center(child: Text(widget.emptyMessage));
    }

    return ListView(
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      children: <Widget>[
        for (final node in widget.roots)
          _TreeBranch(
            node: node,
            pathKey: node.name,
            depth: 0,
            expanded: _expanded,
            onToggle: _toggle,
            onFileTap: widget.onFileTap,
            fileBuilder: widget.fileBuilder,
          ),
      ],
    );
  }

  void _toggle(String key) {
    setState(() {
      if (_expanded.contains(key)) {
        _expanded.remove(key);
      } else {
        _expanded.add(key);
      }
    });
  }
}

class _TreeBranch extends StatelessWidget {
  const _TreeBranch({
    required this.node,
    required this.pathKey,
    required this.depth,
    required this.expanded,
    required this.onToggle,
    required this.onFileTap,
    required this.fileBuilder,
  });

  final GameDataTreeNode node;
  final String pathKey;
  final int depth;
  final Set<String> expanded;
  final ValueChanged<String> onToggle;
  final GameDataTreeFileTap onFileTap;
  final Widget Function(BuildContext context, GameDataTreeNode node)? fileBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final indent = 12.0 + depth * 16.0;

    if (node.isLeaf) {
      final content = fileBuilder?.call(context, node) ??
          ListTile(
            contentPadding: EdgeInsets.only(left: indent, right: AppSpacing.md),
            leading: Icon(
              Icons.description_outlined,
              color: colorScheme.primary,
            ),
            title: Text(node.name),
            subtitle: node.path == null ? null : Text(node.path!),
            onTap: () => onFileTap(node),
          );
      return content;
    }

    final isOpen = expanded.contains(pathKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: () => onToggle(pathKey),
          child: Padding(
            padding: EdgeInsets.fromLTRB(indent, 6, AppSpacing.md, 6),
            child: Row(
              children: <Widget>[
                Icon(
                  isOpen ? Icons.folder_open_rounded : Icons.folder_rounded,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    node.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isOpen ? Icons.expand_less : Icons.expand_more,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (depth > 0)
          Padding(
            padding: EdgeInsets.only(left: indent + 10),
            child: Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        if (isOpen)
          for (final child in node.children)
            _TreeBranch(
              node: child,
              pathKey: '$pathKey/${child.name}',
              depth: depth + 1,
              expanded: expanded,
              onToggle: onToggle,
              onFileTap: onFileTap,
              fileBuilder: fileBuilder,
            ),
      ],
    );
  }
}
