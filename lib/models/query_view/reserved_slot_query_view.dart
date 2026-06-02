import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class ReservedSlotQueryViewModel extends BaseQueryViewModel {
  const ReservedSlotQueryViewModel({this.filter = 0})
    : super(
        classIdentifier:
            'Assembly-CSharp::AI.DataModels.QueryViews.ReservedSlotQueryViewSO',
      );

  final int filter;

  factory ReservedSlotQueryViewModel.fromJson(Map<String, dynamic> json) {
    return ReservedSlotQueryViewModel(filter: (json['filter'] ?? 0) as int);
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'filter': filter};
}
