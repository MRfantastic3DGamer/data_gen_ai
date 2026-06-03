import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/common/registry_catalog_listener.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnimationTypesListScreen extends StatelessWidget {
  const AnimationTypesListScreen({super.key, required this.catalog});

  final RegistryCatalogService catalog;

  @override
  Widget build(BuildContext context) {
    return RegistryCatalogListener(
      child: _AnimationTypesListBody(catalog: catalog),
    );
  }
}

class _AnimationTypesListBody extends StatelessWidget {
  const _AnimationTypesListBody({required this.catalog});

  final RegistryCatalogService catalog;

  @override
  Widget build(BuildContext context) {
    final files = catalog.animationTypesFiles;
    if (files.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Animation types')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No Animation Types Config JSON files found.\n\n'
              'Export from Unity (each character folder may have an '
              '"… Animation Types" asset).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Animation types configs')),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          final factionLabel = file.factionId != null
              ? catalog.factionLabel(file.factionId!)
              : null;
          return ListTile(
            leading: const Icon(Icons.animation),
            title: Text(file.displayName),
            subtitle: Text(
              '${file.model.types.length} type(s)'
              '${factionLabel != null ? ' · Faction: $factionLabel' : ''}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(
              '/registries/animation-types/edit',
              extra: file.path,
            ),
          );
        },
      ),
    );
  }
}
