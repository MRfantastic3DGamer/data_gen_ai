class GraphBlock {
  const GraphBlock({
    required this.id,
    required this.type,
    this.options = const <String, dynamic>{},
  });

  final String id;
  final String type;
  final Map<String, dynamic> options;

  factory GraphBlock.fromJson(Map<String, dynamic> json) {
    return GraphBlock(
      id: json['id'] as String,
      type: json['type'] as String,
      options: Map<String, dynamic>.from(
        json['options'] as Map? ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type,
    'options': options,
  };

  GraphBlock copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? options,
  }) {
    return GraphBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      options: options ?? this.options,
    );
  }
}
