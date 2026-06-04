import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/common/nav_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistriesHubScreen extends StatelessWidget {
  const RegistriesHubScreen({super.key, required this.catalog});

  final RegistryCatalogService catalog;

  @override
  Widget build(BuildContext context) {
    final factionCount = catalog.factionsFile?.model.factions.length ?? 0;
    final animConfigCount = catalog.animationTypesFiles.length;
    final actionCount = catalog.actionCatalogEntries.length;
    final hasCatalogRegistry = catalog.actionCatalogRegistry != null;
    final workTypeCount = catalog.workTypesFile?.model.types.length ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Registries')),
      body: ListView(
        padding: AppSpacing.pagePadding(context),
        children: <Widget>[
          Text(
            'Registry tables power dropdowns across the app — same ids and labels as Unity.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          NavCard(
            title: 'Factions',
            subtitle: factionCount == 0
                ? 'FactionsConfig.json not loaded'
                : '$factionCount faction(s) · character identity',
            icon: Icons.groups_rounded,
            iconColor: colorScheme.primary,
            onTap: () => context.push('/registries/factions'),
          ),
          NavCard(
            title: 'Action catalog',
            subtitle: actionCount == 0 && !hasCatalogRegistry
                ? 'No action catalog JSON found under actionable/'
                : [
                    if (hasCatalogRegistry) 'registry loaded',
                    if (actionCount > 0) '$actionCount nested entr${actionCount == 1 ? 'y' : 'ies'}',
                  ].join(' · '),
            icon: Icons.playlist_play_rounded,
            iconColor: colorScheme.primary,
            delayMs: 30,
            onTap: () => context.push('/registries/actions'),
          ),
          NavCard(
            title: 'Animation types',
            subtitle: animConfigCount == 0
                ? 'No Animation Types JSON found'
                : '$animConfigCount config(s) · per-faction vocabularies',
            icon: Icons.animation_rounded,
            iconColor: colorScheme.secondary,
            delayMs: 40,
            onTap: () => context.push('/registries/animation-types'),
          ),
          NavCard(
            title: 'Work types',
            subtitle: workTypeCount == 0
                ? 'WorkTypesConfig.json not loaded'
                : '$workTypeCount work type(s) · workpost filters',
            icon: Icons.work_outline_rounded,
            iconColor: colorScheme.tertiary,
            delayMs: 80,
            onTap: () => context.push('/registries/work-types'),
          ),
        ],
      ),
    );
  }
}
