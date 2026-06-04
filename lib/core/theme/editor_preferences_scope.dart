import 'package:data_gen_ai/services/editor_preferences_service.dart';
import 'package:flutter/material.dart';

/// Access global editor spacing from the widget tree.
extension EditorPreferencesContext on BuildContext {
  EditorPreferencesService get editorPreferences =>
      EditorPreferencesScope.of(this);

  double get editorFieldPadding => editorPreferences.fieldPadding;

  double get editorFieldGap => editorPreferences.fieldGap;

  EdgeInsets get editorFormPadding => editorPreferences.formPadding;

  EdgeInsets get editorFieldBoxPadding => editorPreferences.fieldBoxPadding;
}

class EditorPreferencesScope extends InheritedNotifier<EditorPreferencesService> {
  const EditorPreferencesScope({
    super.key,
    required EditorPreferencesService preferences,
    required super.child,
  }) : super(notifier: preferences);

  static EditorPreferencesService of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<EditorPreferencesScope>();
    assert(scope != null, 'EditorPreferencesScope not found in widget tree');
    return scope!.notifier!;
  }
}

/// Standard scrollable editor form with global outer padding.
class EditorFormList extends StatelessWidget {
  const EditorFormList({
    super.key,
    required this.children,
    this.controller,
    this.bottomPadding = 24,
  });

  final List<Widget> children;
  final ScrollController? controller;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final padding = context.editorFormPadding;
    return ListView(
      controller: controller,
      padding: padding.copyWith(bottom: padding.bottom + bottomPadding),
      children: children,
    );
  }
}

/// Vertical stack of fields with consistent global spacing.
class EditorFieldGroup extends StatelessWidget {
  const EditorFieldGroup({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gap = context.editorFieldGap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ],
      ],
    );
  }
}

/// Wraps nested row/card editors with half the global field gap.
class EditorNestedBox extends StatelessWidget {
  const EditorNestedBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inset = context.editorFieldGap * 0.65;
    return Padding(
      padding: EdgeInsets.all(inset),
      child: child,
    );
  }
}
