import 'package:flutter/material.dart';

/// ListView for editor forms embedded inside a parent scroll view.
class EditorListView extends StatelessWidget {
  const EditorListView({
    super.key,
    required this.children,
    this.padding,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? const EdgeInsets.all(12),
      children: children,
    );
  }
}
