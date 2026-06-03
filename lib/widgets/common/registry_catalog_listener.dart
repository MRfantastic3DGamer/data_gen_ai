import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reloads [RegistryCatalogService] when game data finishes loading so registry
/// screens never read a stale empty catalog.
class RegistryCatalogListener extends StatefulWidget {
  const RegistryCatalogListener({
    super.key,
    required this.child,
    this.onCatalogReady,
  });

  final Widget child;
  final VoidCallback? onCatalogReady;

  @override
  State<RegistryCatalogListener> createState() =>
      _RegistryCatalogListenerState();
}

class _RegistryCatalogListenerState extends State<RegistryCatalogListener> {
  var _catalogReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCatalog());
  }

  Future<void> _syncCatalog() async {
    final state = context.read<GameDataBloc>().state;
    if (state.loading) {
      if (_catalogReady && mounted) {
        setState(() => _catalogReady = false);
      }
      return;
    }
    await context.read<RegistryCatalogService>().reload(
      context.read<ProjectRepository>(),
    );
    if (!mounted) return;
    setState(() => _catalogReady = true);
    widget.onCatalogReady?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameDataBloc, GameDataState>(
      listenWhen: (previous, current) =>
          previous.loading != current.loading ||
          previous.entries.length != current.entries.length,
      listener: (context, state) => _syncCatalog(),
      child: _catalogReady
          ? widget.child
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
