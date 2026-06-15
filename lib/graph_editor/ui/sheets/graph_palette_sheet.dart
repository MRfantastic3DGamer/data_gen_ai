import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/ui/panels/node_palette_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showGraphPaletteSheet(
  BuildContext context, {
  required GraphEditorCubit cubit,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final sheetHeight = MediaQuery.sizeOf(context).height * 0.78;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: SizedBox(
          height: sheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Add to graph',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: NodePalettePanel(
                  compact: true,
                  onNodeAdded: (displayName) {
                    Navigator.pop(sheetContext);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Added $displayName'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
