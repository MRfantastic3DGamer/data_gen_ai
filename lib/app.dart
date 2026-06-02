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
import 'package:data_gen_ai/repositories/ai_repository.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/repositories/registry_repository.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/gemma_service.dart';
import 'package:data_gen_ai/services/json_converter.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameDataEditorApp extends StatelessWidget {
  const GameDataEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fileService = FileService();
    final jsonConverter = JsonConverterService();
    final projectRepository = ProjectRepository(
      fileService: fileService,
      jsonConverter: jsonConverter,
    );
    final registryCatalog = RegistryCatalogService();
    final registryRepository = RegistryRepository(projectRepository);
    final aiRepository = AIRepository(GemmaService());

    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<FileService>.value(value: fileService),
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
            create: (_) {
              final bloc = GameDataBloc(projectRepository, registryCatalog);
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
        child: MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
