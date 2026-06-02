import 'dart:convert';
import 'dart:io';

import 'package:data_gen_ai/core/constants.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<Directory> getRawRootDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/${AppConstants.rawRootFolder}');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<List<File>> listJsonFiles() async {
    final root = await getRawRootDirectory();
    final entities = root.listSync(recursive: true);
    return entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();
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
