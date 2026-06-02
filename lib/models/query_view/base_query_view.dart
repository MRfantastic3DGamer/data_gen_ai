abstract class BaseQueryViewModel {
  const BaseQueryViewModel({required this.classIdentifier});

  final String classIdentifier;

  Map<String, dynamic> toJson();
}
