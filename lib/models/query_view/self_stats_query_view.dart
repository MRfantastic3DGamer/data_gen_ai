import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class SelfStatsQueryViewModel extends BaseQueryViewModel {
  const SelfStatsQueryViewModel({this.type = 0})
    : super(
        classIdentifier:
            'Assembly-CSharp::AI.DataModels.QueryViews.SelfStatsQueryViewSO',
      );

  final int type;

  factory SelfStatsQueryViewModel.fromJson(Map<String, dynamic> json) {
    return SelfStatsQueryViewModel(type: (json['type'] ?? 0) as int);
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'type': type};
}
