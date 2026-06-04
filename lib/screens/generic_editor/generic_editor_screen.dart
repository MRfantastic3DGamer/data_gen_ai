import 'package:data_gen_ai/blocs/generic_so/generic_so_bloc.dart';
import 'package:data_gen_ai/blocs/generic_so/generic_so_event.dart';
import 'package:data_gen_ai/blocs/generic_so/generic_so_state.dart';
import 'package:data_gen_ai/core/theme/editor_preferences_scope.dart';
import 'package:data_gen_ai/widgets/common/json_preview_panel.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GenericEditorScreen extends StatefulWidget {
  const GenericEditorScreen({super.key});

  @override
  State<GenericEditorScreen> createState() => _GenericEditorScreenState();
}

class _GenericEditorScreenState extends State<GenericEditorScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != null) {
      context.read<GenericSOBloc>().add(GenericSOLoaded(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generic SO Editor')),
      body: BlocBuilder<GenericSOBloc, GenericSOState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: context.editorFormPadding,
            children: <Widget>[
              SectionCard(
                title: 'Raw Payload JSON',
                child: SizedBox(
                  height: 420,
                  child: JsonPreviewPanel(json: state.payload),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final path = GoRouterState.of(context).extra as String?;
          if (path != null) {
            context.read<GenericSOBloc>().add(GenericSOSaved(path));
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      ),
    );
  }
}
