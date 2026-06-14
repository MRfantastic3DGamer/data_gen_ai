import 'dart:ui';

class GraphPosition {
  const GraphPosition({required this.x, required this.y});

  final double x;
  final double y;

  factory GraphPosition.fromJson(Map<String, dynamic> json) {
    return GraphPosition(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'x': x, 'y': y};

  Offset toOffset() => Offset(x, y);

  GraphPosition translate(double dx, double dy) =>
      GraphPosition(x: x + dx, y: y + dy);

  GraphPosition copyWith({double? x, double? y}) =>
      GraphPosition(x: x ?? this.x, y: y ?? this.y);
}
