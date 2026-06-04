import 'package:data_gen_ai/repositories/registry_repository.dart';
import 'package:data_gen_ai/screens/actions/actions_hub_screen.dart';
import 'package:data_gen_ai/screens/actions/so_detail_editor_screen.dart';
import 'package:data_gen_ai/screens/generic_editor/generic_editor_screen.dart';
import 'package:data_gen_ai/screens/home/home_screen.dart';
import 'package:data_gen_ai/screens/item/item_editor_screen.dart';
import 'package:data_gen_ai/screens/item/item_list_screen.dart';
import 'package:data_gen_ai/screens/registries/animation_types_list_screen.dart';
import 'package:data_gen_ai/screens/registries/animation_types_table_screen.dart';
import 'package:data_gen_ai/screens/registries/factions_table_screen.dart';
import 'package:data_gen_ai/screens/registries/registries_hub_screen.dart';
import 'package:data_gen_ai/screens/registries/work_types_table_screen.dart';
import 'package:data_gen_ai/screens/settings/data_folder_screen.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/actions',
        builder: (context, state) => const ActionsHubScreen(),
      ),
      GoRoute(
        path: '/so-edit',
        builder: (context, state) => const SODetailEditorScreen(),
      ),
      GoRoute(
        path: '/data-folder',
        builder: (context, state) => const DataFolderScreen(),
      ),
      GoRoute(
        path: '/registries',
        builder: (context, state) => RegistriesHubScreen(
          catalog: context.read<RegistryCatalogService>(),
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
      GoRoute(
        path: '/items',
        builder: (context, state) => const ItemListScreen(),
      ),
      GoRoute(
        path: '/items/edit',
        builder: (context, state) => const ItemEditorScreen(),
      ),
      GoRoute(
        path: '/browser',
        redirect: (context, state) => '/actions',
      ),
      GoRoute(
        path: '/generic',
        builder: (context, state) => const GenericEditorScreen(),
      ),
    ],
  );
}
