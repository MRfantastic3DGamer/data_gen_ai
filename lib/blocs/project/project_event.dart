import 'package:equatable/equatable.dart';

sealed class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ProjectStarted extends ProjectEvent {
  const ProjectStarted();
}
