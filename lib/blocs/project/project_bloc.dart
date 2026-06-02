import 'package:data_gen_ai/blocs/project/project_event.dart';
import 'package:data_gen_ai/blocs/project/project_state.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(this._projectRepository) : super(const ProjectState()) {
    on<ProjectStarted>(_onStarted);
  }

  final ProjectRepository _projectRepository;

  Future<void> _onStarted(
    ProjectStarted event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final paths = await _projectRepository.listJsonPaths();
      emit(state.copyWith(loading: false, paths: paths));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
