import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class PositioningQueryViewModel extends BaseQueryViewModel {
  const PositioningQueryViewModel({
    this.positionType = 0,
    this.temperatureRange = const <String, dynamic>{'x': 0, 'y': 0},
  }) : super(
         classIdentifier:
             'Assembly-CSharp::AI.DataModels.QueryViews.SensorPositioningQueryViewSO',
       );

  final int positionType;
  final Map<String, dynamic> temperatureRange;

  factory PositioningQueryViewModel.fromJson(Map<String, dynamic> json) {
    return PositioningQueryViewModel(
      positionType: (json['positionType'] ?? 0) as int,
      temperatureRange: Map<String, dynamic>.from(
        json['TemperatureRange'] as Map? ?? <String, dynamic>{'x': 0, 'y': 0},
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'positionType': positionType,
    'TemperatureRange': temperatureRange,
  };
}
