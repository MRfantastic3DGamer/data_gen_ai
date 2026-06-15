import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/ui/panels/node_options_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showGraphOptionsSheet(
  BuildContext context, {
  required GraphEditorCubit cubit,
}) {
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
                  'Node options',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Expanded(child: NodeOptionsPanel()),
            ],
          ),
        ),
      );
    },
  );
}
