import 'package:data_gen_ai/models/registry_option.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Resolves action catalog entry ids from the loaded registry catalog.
class ActionCatalogService {
  const ActionCatalogService._();

  static List<RegistryOption<int>> actionOptions(BuildContext context) {
    return context.read<RegistryCatalogService>().actionOptions();
  }
}
