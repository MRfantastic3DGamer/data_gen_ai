import 'package:data_gen_ai/models/query_view/base_query_view.dart';
import 'package:data_gen_ai/models/unity_reference.dart';

class ScheduleQueryViewModel extends BaseQueryViewModel {
  const ScheduleQueryViewModel({
    this.schedule = const UnityReference(guid: '', fileId: 0),
    this.pointGroup = '',
    this.pointIndex = 0,
  }) : super(
         classIdentifier:
             'Assembly-CSharp::AI.DataModels.QueryViews.ScheduleQueryViewSO',
       );

  final UnityReference schedule;
  final String pointGroup;
  final int pointIndex;

  factory ScheduleQueryViewModel.fromJson(Map<String, dynamic> json) {
    final handle = json['schedule'] as Map<String, dynamic>?;
    return ScheduleQueryViewModel(
      schedule: UnityReference.fromJson(handle),
      pointGroup: (json['pointGroup'] ?? '') as String,
      pointIndex: (json['pointIndex'] ?? 0) as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'schedule': schedule.toJson(),
    'pointGroup': pointGroup,
    'pointIndex': pointIndex,
  };

  ScheduleQueryViewModel copyWith({
    UnityReference? schedule,
    String? pointGroup,
    int? pointIndex,
  }) {
    return ScheduleQueryViewModel(
      schedule: schedule ?? this.schedule,
      pointGroup: pointGroup ?? this.pointGroup,
      pointIndex: pointIndex ?? this.pointIndex,
    );
  }
}
