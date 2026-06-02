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
            title: 'Animation types',
            subtitle: animConfigCount == 0
                ? 'No Animation Types JSON found'
                : '$animConfigCount config(s) · per-faction vocabularies',
            icon: Icons.animation_rounded,
            iconColor: colorScheme.secondary,
            delayMs: 40,
            onTap: () => context.push('/registries/animation-types'),
          ),
        ],
      ),
    );
  }
}
