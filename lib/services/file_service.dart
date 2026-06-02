import 'dart:convert';
import 'dart:io';

import 'package:data_gen_ai/core/constants.dart';
import 'package:data_gen_ai/services/data_folder_service.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  FileService({DataFolderService? dataFolderService})
    : _dataFolderService = dataFolderService ?? DataFolderService();

  final DataFolderService _dataFolderService;

  Future<Directory> getRawRootDirectory() async {
    final custom = await _dataFolderService.getCustomRootPath();
    if (custom != null && custom.isNotEmpty) {
      final directory = Directory(custom);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    }

    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/${AppConstants.rawRootFolder}');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<List<File>> listJsonFiles() async {
    final root = await getRawRootDirectory();
    if (!await root.exists()) return <File>[];

    final files = <File>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.json')) {
        files.add(entity);
      }
    }
    return files;
  }

  Future<String> readFile(String path) async {
    return File(path).readAsString();
  }

  Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }

  Future<void> writeJson(String path, Map<String, dynamic> json) async {
    await writeFile(path, const JsonEncoder.withIndent('  ').convert(json));
  }
}
