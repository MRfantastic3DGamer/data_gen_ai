import 'package:flutter/material.dart';

/// List row for a JSON game-data entry with optional unsaved indicator.
class GameDataListTile extends StatelessWidget {
  const GameDataListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.typeLabel,
    required this.isDirty,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String typeLabel;
  final bool isDirty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isDirty
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            isDirty ? Icons.edit_note_rounded : Icons.description_outlined,
            color: isDirty
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 2),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            _TypeChip(label: typeLabel),
          ],
        ),
        isThreeLine: true,
        trailing: isDirty
            ? Badge(
                label: const Text(' '),
                backgroundColor: colorScheme.tertiary,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
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
