import 'dart:convert';
import 'dart:io';

import 'package:data_gen_ai/core/constants.dart';
import 'package:data_gen_ai/core/platform_support.dart';
import 'package:data_gen_ai/services/data_folder_service.dart';
import 'package:data_gen_ai/services/storage_permission_service.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  /// Shown in Settings when local RAW I/O is unavailable (Flutter web).
  static const String webDataLocationLabel =
      'Local RAW folder is not available in the browser. '
      'Run on Android or desktop, or use Firebase from a native build.';

  FileService({
    DataFolderService? dataFolderService,
    StoragePermissionService? storagePermissionService,
  }) : _dataFolderService = dataFolderService ?? DataFolderService(),
       _storagePermissionService =
           storagePermissionService ?? StoragePermissionService();

  final DataFolderService _dataFolderService;
  final StoragePermissionService _storagePermissionService;

  /// Path label for UI (web-safe).
  Future<String> rawRootPathLabel() async {
    if (!supportsLocalRawFileIo) return webDataLocationLabel;
    final custom = await _dataFolderService.getCustomRootPath();
    if (custom != null && custom.isNotEmpty) return custom;
    return (await getRawRootDirectory()).path;
  }

  Future<Directory> getRawRootDirectory() async {
    if (!supportsLocalRawFileIo) {
      throw UnsupportedError(webDataLocationLabel);
    }
    final custom = await _dataFolderService.getCustomRootPath();
    if (custom != null && custom.isNotEmpty) {
      await _ensureCanAccessExternalPath(custom);
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

  Future<void> _ensureCanAccessExternalPath(String path) async {
    if (!isAndroidDevice) return;

    final docs = await getApplicationDocumentsDirectory();
    if (path.startsWith(docs.path)) return;

    if (!await _storagePermissionService.hasStorageAccess()) {
      final result = await _storagePermissionService.requestStorageAccess();
      if (!result.granted) {
        throw StoragePermissionException(
          result.message ??
              'Storage permission required to access $path',
        );
      }
    }
  }

  Future<List<File>> listJsonFiles() async {
    if (!supportsLocalRawFileIo) return <File>[];
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

  Future<List<File>> listMetaFiles() async {
    if (!supportsLocalRawFileIo) return <File>[];
    final root = await getRawRootDirectory();
    if (!await root.exists()) return <File>[];

    final files = <File>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.meta')) {
        files.add(entity);
      }
    }
    return files;
  }

  Future<String> readFile(String path) async {
    if (!supportsLocalRawFileIo) {
      throw UnsupportedError(webDataLocationLabel);
    }
    if (isAndroidDevice) {
      await _ensureCanAccessExternalPath(File(path).parent.path);
    }
    return File(path).readAsString();
  }

  Future<void> writeFile(String path, String content) async {
    if (!supportsLocalRawFileIo) {
      throw UnsupportedError(webDataLocationLabel);
    }
    if (isAndroidDevice) {
      await _ensureCanAccessExternalPath(File(path).parent.path);
    }
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }

  Future<void> writeJson(String path, Map<String, dynamic> json) async {
    await writeFile(path, const JsonEncoder.withIndent('  ').convert(json));
  }

  Future<void> deleteFile(String path) async {
    if (!supportsLocalRawFileIo) {
      throw UnsupportedError(webDataLocationLabel);
    }
    if (isAndroidDevice) {
      await _ensureCanAccessExternalPath(File(path).parent.path);
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    final meta = File('$path.meta');
    if (await meta.exists()) {
      await meta.delete();
    }
  }

  /// Removes all files under the RAW root so a Firebase pull matches remote exactly.
  Future<void> clearRawRootDirectory() async {
    if (!supportsLocalRawFileIo) return;
    final root = await getRawRootDirectory();
    if (!await root.exists()) {
      await root.create(recursive: true);
      return;
    }
    await for (final entity in root.list(recursive: false)) {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await entity.delete(recursive: true);
      }
    }
  }
}
