import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Home-screen navigation tile with icon, title, subtitle, and optional path expander.
class NavCard extends StatefulWidget {
  const NavCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.delayMs = 0,
    this.filePath,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final int delayMs;
  final String? filePath;

  @override
  State<NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<NavCard> {
  var _pathExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = widget.iconColor ?? colorScheme.primary;
    final path = widget.filePath;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: accent, size: 26),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ],
              ),
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
    )
        .animate(delay: Duration(milliseconds: widget.delayMs))
        .fadeIn(duration: 280.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 280.ms, curve: Curves.easeOutCubic);
  }
}
