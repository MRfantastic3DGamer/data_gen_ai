import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class ThreatAdvertisementQueryViewModel extends BaseQueryViewModel {
  const ThreatAdvertisementQueryViewModel({this.range = 0, this.threatType = 0})
    : super(
        classIdentifier:
            'Assembly-CSharp::AI.DataModels.QueryViews.ThreatAdvertisementQueryViewSO',
      );

  final double range;
  final int threatType;

  factory ThreatAdvertisementQueryViewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ThreatAdvertisementQueryViewModel(
      range: (json['range'] ?? 0).toDouble(),
      threatType: (json['threatType'] ?? 0) as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'range': range,
    'threatType': threatType,
  };
}
