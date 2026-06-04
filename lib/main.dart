import 'package:data_gen_ai/app.dart';
import 'package:data_gen_ai/core/platform_support.dart';
import 'package:data_gen_ai/firebase_options.dart';
import 'package:data_gen_ai/services/game_data_backend_service.dart';
import 'package:data_gen_ai/services/storage_permission_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final backendService = GameDataBackendService();
  await backendService.load();

  if (isAndroidDevice) {
    await StoragePermissionService().requestStorageAccess();
  }

  runApp(GameDataEditorApp(backendService: backendService));
}
