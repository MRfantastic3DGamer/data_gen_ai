import 'dart:io';

import 'package:data_gen_ai/app.dart';
import 'package:data_gen_ai/services/storage_permission_service.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await StoragePermissionService().requestStorageAccess();
  }

  runApp(const GameDataEditorApp());
}
