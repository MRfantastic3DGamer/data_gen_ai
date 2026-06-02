import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/project/project_bloc.dart';
import 'package:data_gen_ai/blocs/project/project_event.dart';
import 'package:data_gen_ai/core/enums/game_data_backend.dart';
import 'package:data_gen_ai/core/firebase_constants.dart';
import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/data_folder_service.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/game_data_backend_service.dart';
import 'package:data_gen_ai/services/storage_permission_service.dart';
import 'package:data_gen_ai/widgets/common/app_snackbar.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataFolderScreen extends StatefulWidget {
  const DataFolderScreen({super.key});

  @override
  State<DataFolderScreen> createState() => _DataFolderScreenState();
}

class _DataFolderScreenState extends State<DataFolderScreen> {
  final StoragePermissionService _permissions = StoragePermissionService();

  GameDataBackend _backend = GameDataBackend.firebase;
  String? _currentPath;
  String? _firebaseLocation;
  var _loading = true;
  var _hasStorageAccess = true;
  var _needsSettings = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final backendService = context.read<GameDataBackendService>();
    final custom = await DataFolderService().getCustomRootPath();
    final defaultRoot = await context.read<FileService>().getRawRootDirectory();
    final access = await _permissions.hasStorageAccess();
    final location = await context.read<ProjectRepository>().dataLocationLabel();
    if (!mounted) return;
    setState(() {
      _backend = backendService.backend;
      _currentPath = custom ?? defaultRoot.path;
      _firebaseLocation = location;
      _loading = false;
      _hasStorageAccess = access;
    });
  }

  Future<void> _setBackend(GameDataBackend backend) async {
    await context.read<GameDataBackendService>().setBackend(backend);
    if (!mounted) return;
    setState(() => _backend = backend);
    _reloadData();
    AppSnackBar.showSuccess(
      context,
      backend == GameDataBackend.firebase
          ? 'Using Firebase Realtime Database.'
          : 'Using local JSON folder.',
    );
  }

  void _reloadData() {
    context.read<GameDataBloc>().add(const GameDataReloadRequested());
    context.read<ProjectBloc>().add(const ProjectStarted());
  }

  Future<void> _requestPermissions() async {
    final result = await _permissions.requestStorageAccess();
    if (!mounted) return;
    setState(() {
      _hasStorageAccess = result.granted;
      _needsSettings = result.needsAllFilesSettings;
    });
    if (result.granted) {
      AppSnackBar.showSuccess(context, 'Storage access granted.');
    } else if (result.message != null) {
      AppSnackBar.showError(context, result.message!);
    }
  }

  Future<void> _pickFolder() async {
    if (!await _ensureAccess()) return;

    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    try {
      await DataFolderService().setCustomRootPath(result);
      if (!mounted) return;
      setState(() => _currentPath = result);
      _reloadData();
      AppSnackBar.showSuccess(context, 'Data folder updated.');
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Could not use folder: $e');
    }
  }

  Future<bool> _ensureAccess() async {
    if (await _permissions.hasStorageAccess()) return true;
    final result = await _permissions.requestStorageAccess();
    if (!mounted) return false;
    setState(() {
      _hasStorageAccess = result.granted;
      _needsSettings = result.needsAllFilesSettings;
    });
    return result.granted;
  }

  Future<void> _useDefault() async {
    await DataFolderService().setCustomRootPath(null);
    await _load();
    if (!mounted) return;
    _reloadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data source')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.pagePadding(context),
              children: <Widget>[
                SectionCard(
                  title: 'Storage backend',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ...GameDataBackend.values.map(
                        (b) => RadioListTile<GameDataBackend>(
                          title: Text(b.label),
                          subtitle: Text(
                            b == GameDataBackend.firebase
                                ? FirebaseGameDataConstants.databaseUrl
                                : 'USB / copied RAW folder on device',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          value: b,
                          groupValue: _backend,
                          onChanged: (value) {
                            if (value != null) _setBackend(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_backend == GameDataBackend.firebase) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Firebase Realtime Database',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SelectableText(
                            _firebaseLocation ??
                                FirebaseGameDataConstants.databaseUrl,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Edits commit directly to '
                            '${FirebaseGameDataConstants.filesRoot}/. '
                            'Use Unity → Tools → Agent Actions → Pull from Firebase '
                            'to apply changes in the editor.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_backend == GameDataBackend.localFiles) ...<Widget>[
                  if (!_hasStorageAccess)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Storage permission required',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FilledButton(
                              onPressed: _requestPermissions,
                              child: const Text('Grant storage access'),
                            ),
                            if (_needsSettings) ...<Widget>[
                              const SizedBox(height: AppSpacing.sm),
                              OutlinedButton(
                                onPressed: () => _permissions
                                    .openAppPermissionSettings(),
                                child: const Text('Open app settings'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  SectionCard(
                    title: 'Local workflow',
                    child: Text(
                      '1. Unity → Export GameData to JSON (or Pull from Firebase)\n'
                      '2. Copy RAW to the phone (optional if using Firebase)\n'
                      '3. Choose folder below\n'
                      '4. Edit and Commit\n'
                      '5. Unity Import or Push to Firebase',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Current folder',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SelectableText(
                            _currentPath ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton.icon(
                            onPressed: _pickFolder,
                            icon: const Icon(Icons.folder_open_rounded),
                            label: const Text('Choose folder'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: _useDefault,
                            child: const Text('Use app documents default'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
