import 'package:flutter/material.dart';

/// List row for a JSON game-data entry with optional unsaved indicator and path expander.
class GameDataListTile extends StatefulWidget {
  const GameDataListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.typeLabel,
    required this.isDirty,
    required this.onTap,
    this.filePath,
  });

  final String title;
  final String subtitle;
  final String typeLabel;
  final bool isDirty;
  final VoidCallback onTap;
  final String? filePath;

  @override
  State<GameDataListTile> createState() => _GameDataListTileState();
}

class _GameDataListTileState extends State<GameDataListTile> {
  var _pathExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final path = widget.filePath;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            onTap: widget.onTap,
            leading: CircleAvatar(
              backgroundColor: widget.isDirty
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              child: Icon(
                widget.isDirty ? Icons.edit_note_rounded : Icons.description_outlined,
                color: widget.isDirty
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _TypeChip(label: widget.typeLabel),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (path != null && path.isNotEmpty)
                  IconButton(
                    tooltip: _pathExpanded ? 'Hide path' : 'Show path',
                    icon: Icon(
                      _pathExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                    onPressed: () =>
                        setState(() => _pathExpanded = !_pathExpanded),
                  ),
                if (widget.isDirty)
                  Badge(
                    label: const Text(' '),
                    backgroundColor: colorScheme.tertiary,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          if (_pathExpanded && path != null && path.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SelectableText(
                path,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(label),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        labelStyle: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
