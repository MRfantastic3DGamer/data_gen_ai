import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/services/data_folder_service.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/storage_permission_service.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage access granted.')),
      );
    } else if (result.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data folder updated. Reloaded JSON files.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not use folder: $e')),
      );
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
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                if (!_hasStorageAccess)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Storage permission required',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'To create and edit JSON files in your copied RAW folder, '
                            'allow full file access (All files access on Android 11+).',
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _requestPermissions,
                            child: const Text('Grant storage access'),
                          ),
                          if (_needsSettings) ...<Widget>[
                            const SizedBox(height: 8),
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
                Text(
                  'Workflow',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. In Unity: Tools → Agent Actions → Export GameData ScriptableObjects to JSON\n'
                  '2. Copy the Assets/GameData/RAW folder to your phone\n'
                  '3. Grant storage access above, then select that folder\n'
                  '4. Edit in this app and tap Commit\n'
                  '5. Copy RAW back to Unity and run Import JSON to GameData',
                ),
                const SizedBox(height: 24),
                Text(
                  'Current folder',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(_currentPath ?? ''),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _pickFolder,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose folder'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _useDefault,
                  child: const Text('Use app documents default'),
                ),
              ],
            ),
    );
  }
}
