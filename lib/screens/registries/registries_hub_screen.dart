import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistriesHubScreen extends StatelessWidget {
  const RegistriesHubScreen({super.key, required this.catalog});

  final RegistryCatalogService catalog;

  @override
  Widget build(BuildContext context) {
    final factionCount = catalog.factionsFile?.model.factions.length ?? 0;
    final animConfigCount = catalog.animationTypesFiles.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Registries')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'These tables mirror Unity\'s Factions Config and Animation Types Config. '
            'Dropdowns across the app use the same ids and labels as the Unity editor.',
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Factions (characters)'),
              subtitle: Text(
                factionCount == 0
                    ? 'FactionsConfig.json not loaded'
                    : '$factionCount faction(s)',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/registries/factions'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.animation_outlined),
              title: const Text('Animation types'),
              subtitle: Text(
                animConfigCount == 0
                    ? 'No Animation Types JSON found'
                    : '$animConfigCount config(s)',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/registries/animation-types'),
            ),
          ),
        ],
      ),
    );
  }
}
