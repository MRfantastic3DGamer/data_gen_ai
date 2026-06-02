import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/services/data_folder_service.dart';
import 'package:data_gen_ai/services/file_service.dart';
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
  var _hasStorageAccess = true;
  var _needsSettings = false;

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
      context.read<GameDataBloc>().add(const GameDataReloadRequested());
      AppSnackBar.showSuccess(
        context,
        'Data folder updated. Reloaded JSON files.',
      );
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
    context.read<GameDataBloc>().add(const GameDataReloadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON data folder')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.pagePadding(context),
              children: <Widget>[
                if (!_hasStorageAccess)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.lock_outline_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Storage permission required',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Allow full file access so the app can create and edit JSON in your RAW folder.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
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
                              onPressed: () =>
                                  _permissions.openAppPermissionSettings(),
                              child: const Text('Open app settings'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                SectionCard(
                  title: 'Workflow',
                  child: Text(
                    '1. Unity → Export GameData to JSON\n'
                    '2. Copy RAW folder to your phone\n'
                    '3. Grant storage access, then choose folder\n'
                    '4. Edit and Commit\n'
                    '5. Copy back → Unity Import',
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
            ),
    );
  }
}
