import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_bloc.dart';
import 'package:data_gen_ai/blocs/character/character_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/generic_so/generic_so_bloc.dart';
import 'package:data_gen_ai/blocs/item/item_bloc.dart';
import 'package:data_gen_ai/blocs/project/project_bloc.dart';
import 'package:data_gen_ai/blocs/project/project_event.dart';
import 'package:data_gen_ai/core/constants.dart';
import 'package:data_gen_ai/core/routing/app_router.dart';
import 'package:data_gen_ai/core/theme/app_theme.dart';
import 'package:data_gen_ai/core/theme/editor_preferences_scope.dart';
import 'package:data_gen_ai/repositories/ai_repository.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/repositories/registry_repository.dart';
import 'package:data_gen_ai/services/asset_index_service.dart';
import 'package:data_gen_ai/services/editor_preferences_service.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/game_data_backend_service.dart';
import 'package:data_gen_ai/services/game_data_sync_service.dart';
import 'package:data_gen_ai/services/gemma_service.dart';
import 'package:data_gen_ai/services/json_converter.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameDataEditorApp extends StatefulWidget {
  const GameDataEditorApp({super.key, required this.backendService});

  final GameDataBackendService backendService;

  @override
  State<GameDataEditorApp> createState() => _GameDataEditorAppState();
}

class _GameDataEditorAppState extends State<GameDataEditorApp> {
  late final EditorPreferencesService _editorPreferences;

  @override
  void initState() {
    super.initState();
    _editorPreferences = EditorPreferencesService();
    _editorPreferences.load();
  }

  @override
  void dispose() {
    _editorPreferences.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileService = FileService();
    final jsonConverter = JsonConverterService();
    final projectRepository = ProjectRepository(
      backendService: widget.backendService,
      jsonConverter: jsonConverter,
      fileService: fileService,
    );
    final registryCatalog = RegistryCatalogService();
    final registryRepository = RegistryRepository(projectRepository);
    final aiRepository = AIRepository(GemmaService());
    final syncService = GameDataSyncService(
      firebaseStorage: widget.backendService.firebaseStorage,
      localStorage: widget.backendService.localStorage,
    );

    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<GameDataBackendService>.value(
          value: widget.backendService,
        ),
        RepositoryProvider<GameDataSyncService>.value(value: syncService),
        RepositoryProvider<FileService>.value(value: fileService),
        RepositoryProvider<AssetIndexService>(
          create: (c) => AssetIndexService(c.read<FileService>()),
        ),
        RepositoryProvider<JsonConverterService>.value(value: jsonConverter),
        RepositoryProvider<ProjectRepository>.value(value: projectRepository),
        RepositoryProvider<RegistryCatalogService>.value(value: registryCatalog),
        RepositoryProvider<RegistryRepository>.value(value: registryRepository),
        RepositoryProvider<AIRepository>.value(value: aiRepository),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<ProjectBloc>(
            create: (_) {
              final bloc = ProjectBloc(projectRepository);
              bloc.add(const ProjectStarted());
              return bloc;
            },
          ),
          BlocProvider<GameDataBloc>(
            create: (c) {
              final bloc = GameDataBloc(
                projectRepository,
                registryCatalog,
                c.read<AssetIndexService>(),
              );
              bloc.add(const GameDataStarted());
              return bloc;
            },
          ),
          BlocProvider<CharacterBloc>(
            create: (_) => CharacterBloc(projectRepository, jsonConverter),
          ),
          BlocProvider<ItemBloc>(
            create: (_) => ItemBloc(projectRepository, jsonConverter),
          ),
          BlocProvider<GenericSOBloc>(
            create: (_) => GenericSOBloc(projectRepository, jsonConverter),
          ),
          BlocProvider<AIAssistantBloc>(
            create: (_) => AIAssistantBloc(aiRepository),
          ),
        ],
        child: EditorPreferencesScope(
          preferences: _editorPreferences,
          child: ListenableBuilder(
            listenable: _editorPreferences,
            builder: (context, _) {
              final fieldPadding = _editorPreferences.fieldBoxPadding;
              return MaterialApp.router(
                title: AppConstants.appName,
                theme: AppTheme.applyEditorPreferences(
                  AppTheme.light,
                  fieldPadding,
                ),
                darkTheme: AppTheme.applyEditorPreferences(
                  AppTheme.dark,
                  fieldPadding,
                ),
                themeMode: ThemeMode.system,
                routerConfig: AppRouter.router,
              );
            },
          ),
        ),
      ),
    );
  }
}
