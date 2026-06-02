import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Ensures the app can read/write JSON under external storage paths on Android.
class StoragePermissionService {
  /// Returns true when storage access is sufficient for file I/O.
  Future<bool> hasStorageAccess() async {
    if (!Platform.isAndroid) return true;

    if (await Permission.manageExternalStorage.isGranted) return true;

    // Pre-Android 11 scoped legacy permission.
    if (await Permission.storage.isGranted) return true;

    return false;
  }

  /// Requests storage permissions. On Android 11+ may open system settings for
  /// "All files access".
  Future<StorageAccessResult> requestStorageAccess() async {
    if (!Platform.isAndroid) {
      return const StorageAccessResult(granted: true);
    }

    if (await hasStorageAccess()) {
      return const StorageAccessResult(granted: true);
    }

    var status = await Permission.storage.request();
    if (status.isGranted) {
      return const StorageAccessResult(granted: true);
    }

    status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      return const StorageAccessResult(granted: true);
    }

    if (status.isPermanentlyDenied || !status.isGranted) {
      return const StorageAccessResult(
        granted: false,
        needsAllFilesSettings: true,
        message:
            'Allow "All files access" so the app can create and edit JSON in your RAW folder.',
      );
    }

    return StorageAccessResult(
      granted: false,
      message: 'Storage permission denied ($status).',
    );
  }

  Future<void> openAppPermissionSettings() => openAppSettings();
}

class StorageAccessResult {
  const StorageAccessResult({
    required this.granted,
    this.needsAllFilesSettings = false,
    this.message,
  });

  final bool granted;
  final bool needsAllFilesSettings;
  final String? message;
}

class StoragePermissionException implements Exception {
  StoragePermissionException(this.message);
  final String message;

  @override
  String toString() => message;
}
