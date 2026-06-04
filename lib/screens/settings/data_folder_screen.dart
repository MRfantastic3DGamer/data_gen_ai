import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/project/project_bloc.dart';
import 'package:data_gen_ai/blocs/project/project_event.dart';
import 'package:data_gen_ai/core/firebase_constants.dart';
import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/services/data_folder_service.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/editor_preferences_service.dart';
import 'package:data_gen_ai/services/game_data_backend_service.dart';
import 'package:data_gen_ai/services/game_data_sync_service.dart';
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

  String? _currentPath;
  var _loading = true;
  var _syncing = false;
  var _hasStorageAccess = true;
  var _needsSettings = false;
  String? _syncStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final custom = await DataFolderService().getCustomRootPath();
    final defaultRoot = await context.read<FileService>().getRawRootDirectory();
    final access = await _permissions.hasStorageAccess();
    if (!mounted) return;
    setState(() {
      _currentPath = custom ?? defaultRoot.path;
      _loading = false;
      _hasStorageAccess = access;
    });
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
      AppSnackBar.showSuccess(context, 'Working folder updated.');
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

  Future<void> _pullFromFirebase() async {
    if (!await _ensureAccess()) return;

    setState(() {
      _syncing = true;
      _syncStatus = 'Pulling from Firebase…';
    });

    try {
      final sync = context.read<GameDataSyncService>();
      final result = await sync.pullFromFirebase(
        onProgress: (current, total, key) {
          if (!mounted) return;
          setState(() => _syncStatus = 'Pulling $current / $total\n$key');
        },
      );
      if (!mounted) return;
      _reloadData();
      AppSnackBar.showSuccess(
        context,
        'Pulled ${result.fileCount} file(s) into your local folder.',
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Pull failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
          _syncStatus = null;
        });
      }
    }
  }

  Future<void> _pushToFirebase() async {
    setState(() {
      _syncing = true;
      _syncStatus = 'Pushing to Firebase…';
    });

    try {
      final sync = context.read<GameDataSyncService>();
      final result = await sync.pushToFirebase(
        onProgress: (current, total, key) {
          if (!mounted) return;
          setState(() => _syncStatus = 'Pushing $current / $total\n$key');
        },
      );
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        'Pushed ${result.fileCount} file(s) to Firebase.',
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Push failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
          _syncStatus = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: <Widget>[
                ListView(
                  padding: AppSpacing.pagePadding(context),
                  children: <Widget>[
                    SectionCard(
                      title: 'How it works',
                      child: Text(
                        'All editing uses the local RAW folder on this device. '
                        'Pull once to download the latest from Firebase, design offline, '
                        'then push when you are ready to publish.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SectionCard(
                      title: 'Firebase sync',
                      subtitle: FirebaseGameDataConstants.databaseUrl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          FilledButton.icon(
                            onPressed: _syncing ? null : _pullFromFirebase,
                            icon: const Icon(Icons.cloud_download_rounded),
                            label: const Text('Pull all from Firebase'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          FilledButton.tonalIcon(
                            onPressed: _syncing ? null : _pushToFirebase,
                            icon: const Icon(Icons.cloud_upload_rounded),
                            label: const Text('Push local folder to Firebase'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
                    if (!_hasStorageAccess) const SizedBox(height: AppSpacing.md),
                    SectionCard(
                      title: 'Local working folder',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SelectableText(
                            _currentPath ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton.icon(
                            onPressed: _syncing ? null : _pickFolder,
                            icon: const Icon(Icons.folder_open_rounded),
                            label: const Text('Choose folder'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: _syncing ? null : _useDefault,
                            child: const Text('Use app documents default'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SectionCard(
                      title: 'Editor layout',
                      subtitle: 'Applies to all field boxes and form spacing',
                      child: _EditorLayoutSettings(
                        preferences: context.read<EditorPreferencesService>(),
                      ),
                    ),
                  ],
                ),
                if (_syncing)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const CircularProgressIndicator(),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _syncStatus ?? 'Syncing…',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _EditorLayoutSettings extends StatefulWidget {
  const _EditorLayoutSettings({required this.preferences});

  final EditorPreferencesService preferences;

  @override
  State<_EditorLayoutSettings> createState() => _EditorLayoutSettingsState();
}

class _EditorLayoutSettingsState extends State<_EditorLayoutSettings> {
  late double _fieldPadding;
  late double _fieldGap;

  @override
  void initState() {
    super.initState();
    _fieldPadding = widget.preferences.fieldPadding;
    _fieldGap = widget.preferences.fieldGap;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Field box padding: ${_fieldPadding.round()} px',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Slider(
          min: EditorPreferencesService.minFieldPadding,
          max: EditorPreferencesService.maxFieldPadding,
          divisions: 8,
          value: _fieldPadding,
          label: _fieldPadding.round().toString(),
          onChanged: (v) => setState(() => _fieldPadding = v),
          onChangeEnd: widget.preferences.setFieldPadding,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Space between fields: ${_fieldGap.round()} px',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Slider(
          min: EditorPreferencesService.minFieldGap,
          max: EditorPreferencesService.maxFieldGap,
          divisions: 10,
          value: _fieldGap,
          label: _fieldGap.round().toString(),
          onChanged: (v) => setState(() => _fieldGap = v),
          onChangeEnd: widget.preferences.setFieldGap,
        ),
      ],
    );
  }
}
