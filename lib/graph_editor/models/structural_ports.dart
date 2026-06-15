/// Structural ports for context ↔ block attachment (not data flow).
abstract final class StructuralPorts {
  /// Bottom output on context nodes; accepts multiple block connections.
  static const blocks = 'Blocks';

  /// Top input on block nodes; connects to a parent context node.
  static const block = 'Block';
}
