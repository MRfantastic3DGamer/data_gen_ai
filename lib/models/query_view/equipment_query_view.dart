import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class EquipmentQueryViewModel extends BaseQueryViewModel {
  const EquipmentQueryViewModel({this.itemType = const <String, dynamic>{}})
    : super(
        classIdentifier:
            'Assembly-CSharp::AI.DataModels.QueryViews.EquipmentQueryViewSO',
      );

  final Map<String, dynamic> itemType;

  factory EquipmentQueryViewModel.fromJson(Map<String, dynamic> json) {
    return EquipmentQueryViewModel(
      itemType: Map<String, dynamic>.from(
        json['itemType'] as Map? ?? <String, dynamic>{},
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'itemType': itemType};
}
