import 'package:equatable/equatable.dart';

class ProjectState extends Equatable {
  const ProjectState({
    this.loading = false,
    this.paths = const <String>[],
    this.error,
  });

  final bool loading;
  final List<String> paths;
  final String? error;

  ProjectState copyWith({bool? loading, List<String>? paths, String? error}) {
    return ProjectState(
      loading: loading ?? this.loading,
      paths: paths ?? this.paths,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[loading, paths, error];
}
