import 'package:data_gen_ai/models/query_view/base_query_view.dart';
import 'package:data_gen_ai/models/unity_reference.dart';

class WorkpostQueryViewModel extends BaseQueryViewModel {
  const WorkpostQueryViewModel({
    this.workTypes = const UnityReference(guid: '', fileId: 0),
    this.typeFilterBitIndex = 0,
    this.variantFilter = 0,
    this.minPriority = 0,
    this.maxRange = 50,
    this.unassignedOnly = true,
  }) : super(
         classIdentifier:
             'Assembly-CSharp::AI.DataModels.QueryViews.WorkpostQueryViewSO',
       );

  final UnityReference workTypes;
  final int typeFilterBitIndex;
  final int variantFilter;
  final int minPriority;
  final double maxRange;
  final bool unassignedOnly;

  factory WorkpostQueryViewModel.fromJson(Map<String, dynamic> json) =>
      WorkpostQueryViewModel(
        workTypes: UnityReference.fromJson(
          json['workTypes'] as Map<String, dynamic>?,
        ),
        typeFilterBitIndex: (json['typeFilterBitIndex'] ?? 0) as int,
        variantFilter: (json['variantFilter'] ?? 0) as int,
        minPriority: (json['minPriority'] ?? 0) as int,
        maxRange: (json['maxRange'] ?? 50).toDouble(),
        unassignedOnly: json['unassignedOnly'] != false,
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'workTypes': workTypes.toJson(),
    'typeFilterBitIndex': typeFilterBitIndex,
    'variantFilter': variantFilter,
    'minPriority': minPriority,
    'maxRange': maxRange,
    'unassignedOnly': unassignedOnly,
  };

  WorkpostQueryViewModel copyWith({
    UnityReference? workTypes,
    int? typeFilterBitIndex,
    int? variantFilter,
    int? minPriority,
    double? maxRange,
    bool? unassignedOnly,
  }) {
    return WorkpostQueryViewModel(
      workTypes: workTypes ?? this.workTypes,
      typeFilterBitIndex: typeFilterBitIndex ?? this.typeFilterBitIndex,
      variantFilter: variantFilter ?? this.variantFilter,
      minPriority: minPriority ?? this.minPriority,
      maxRange: maxRange ?? this.maxRange,
      unassignedOnly: unassignedOnly ?? this.unassignedOnly,
    );
  }
}
