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

    return Scaffold(
      appBar: AppBar(title: const Text('Animation types configs')),
      body: files.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No Animation Types Config files in the local data folder yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  title: Text(file.displayName),
                  subtitle: Text(file.path),
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
