import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class InventoryQueryViewModel extends BaseQueryViewModel {
  const InventoryQueryViewModel({this.itemType = const <String, dynamic>{}})
    : super(
        classIdentifier:
            'Assembly-CSharp::AI.DataModels.QueryViews.InventoryQueryViewSO',
      );

  final Map<String, dynamic> itemType;

  factory InventoryQueryViewModel.fromJson(Map<String, dynamic> json) {
    return InventoryQueryViewModel(
      itemType: Map<String, dynamic>.from(
        json['itemType'] as Map? ?? <String, dynamic>{},
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'itemType': itemType};
}
