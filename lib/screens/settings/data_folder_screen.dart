import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/services/data_folder_service.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataFolderScreen extends StatefulWidget {
  const DataFolderScreen({super.key});

  @override
  State<DataFolderScreen> createState() => _DataFolderScreenState();
}

class _DataFolderScreenState extends State<DataFolderScreen> {
  String? _currentPath;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final custom = await DataFolderService().getCustomRootPath();
    final defaultRoot = await context.read<FileService>().getRawRootDirectory();
    if (!mounted) return;
    setState(() {
      _currentPath = custom ?? defaultRoot.path;
      _loading = false;
    });
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;
    await DataFolderService().setCustomRootPath(result);
    if (!mounted) return;
    setState(() => _currentPath = result);
    context.read<GameDataBloc>().add(const GameDataReloadRequested());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data folder updated. Reloaded JSON files.')),
    );
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
                Text(
                  'Workflow',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. In Unity: Tools → Agent Actions → Export GameData ScriptableObjects to JSON\n'
                  '2. Copy the Assets/GameData/RAW folder to your phone\n'
                  '3. Select that folder below\n'
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
