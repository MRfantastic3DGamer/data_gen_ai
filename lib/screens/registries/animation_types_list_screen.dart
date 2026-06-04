import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/so_edit_route_args.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/common/registry_catalog_listener.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnimationTypesListScreen extends StatelessWidget {
  const AnimationTypesListScreen({super.key, required this.catalog});

  final RegistryCatalogService catalog;

  void _createNew(BuildContext context) {
    final typeInfo = SOTypeRegistry.all.firstWhere(
      (t) => t.key == 'AnimationTypesConfig',
    );
    context.push(
      '/so-edit',
      extra: SOEditRouteArgs(
        typeInfo: typeInfo,
        suggestedFolder: 'Animations',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegistryCatalogListener(
      child: _AnimationTypesListBody(
        catalog: catalog,
        onCreateNew: () => _createNew(context),
      ),
    );
  }
}

class _AnimationTypesListBody extends StatelessWidget {
  const _AnimationTypesListBody({
    required this.catalog,
    required this.onCreateNew,
  });

  final RegistryCatalogService catalog;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    final files = catalog.animationTypesFiles;

    return Scaffold(
      appBar: AppBar(title: const Text('Animation types configs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreateNew,
        icon: const Icon(Icons.add),
        label: const Text('New config'),
      ),
      body: files.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'No Animation Types Config files yet.\n\n'
                      'Create configs for Humanoid, Goblin, or other armatures — '
                      'same table format as Humanoid Animation Types.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: onCreateNew,
                      icon: const Icon(Icons.add),
                      label: const Text('Create animation types config'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
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
                    '${file.path}\n'
                    '${file.model.types.length} type(s)'
                    '${factionLabel != null ? ' · Faction: $factionLabel' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    '/so-edit',
                    extra: SOEditRouteArgs(existingPath: file.path),
                  ),
                );
              },
            ),
    );
  }
}
