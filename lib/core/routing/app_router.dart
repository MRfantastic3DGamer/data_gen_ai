import 'package:data_gen_ai/graph_editor/ui/graph_editor_screen.dart';
import 'package:data_gen_ai/graph_editor/ui/graph_list_screen.dart';
import 'package:data_gen_ai/screens/home/home_screen.dart';
import 'package:data_gen_ai/screens/registries/actions_table_screen.dart';
import 'package:data_gen_ai/screens/registries/animation_types_list_screen.dart';
import 'package:data_gen_ai/screens/registries/animation_types_table_screen.dart';
import 'package:data_gen_ai/screens/registries/factions_table_screen.dart';
import 'package:data_gen_ai/screens/registries/registries_hub_screen.dart';
import 'package:data_gen_ai/screens/registries/work_types_table_screen.dart';
import 'package:data_gen_ai/screens/settings/data_folder_screen.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/common/registry_catalog_listener.dart';
import 'package:data_gen_ai/repositories/registry_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/graphs',
        builder: (context, state) => const GraphListScreen(),
      ),
      GoRoute(
        path: '/graphs/edit',
        builder: (context, state) {
          final key = state.extra as String? ?? '';
          return GraphEditorScreen(fileKey: key);
        },
      ),
      GoRoute(
        path: '/data-folder',
        builder: (context, state) => const DataFolderScreen(),
      ),
      GoRoute(
        path: '/registries',
        builder: (context, state) => RegistryCatalogListener(
          child: RegistriesHubScreen(
            catalog: context.read<RegistryCatalogService>(),
          ),
        ),
      ),
      GoRoute(
        path: '/registries/actions',
        builder: (context, state) => RegistryCatalogListener(
          child: ActionsTableScreen(
            catalog: context.read<RegistryCatalogService>(),
          ),
        ),
      ),
      GoRoute(
        path: '/registries/factions',
        builder: (context, state) => FactionsTableScreen(
          catalog: context.read<RegistryCatalogService>(),
          registryRepository: context.read<RegistryRepository>(),
        ),
      ),
      GoRoute(
        path: '/registries/animation-types',
        builder: (context, state) => AnimationTypesListScreen(
          catalog: context.read<RegistryCatalogService>(),
        ),
      ),
      GoRoute(
        path: '/registries/animation-types/edit',
        builder: (context, state) => AnimationTypesTableScreen(
          catalog: context.read<RegistryCatalogService>(),
          registryRepository: context.read<RegistryRepository>(),
        ),
      ),
      GoRoute(
        path: '/registries/work-types',
        builder: (context, state) => WorkTypesTableScreen(
          catalog: context.read<RegistryCatalogService>(),
          registryRepository: context.read<RegistryRepository>(),
        ),
      ),
    ],
  );
}
