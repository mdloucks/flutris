import 'package:flutris/features/layout_validation/models/flutris_point.dart';

extension FlutrisPointListJson on List<FlutrisPoint> {
  List<Map<String, dynamic>> toJson() {
    return map((e) => e.toJson()).toList();
  }
}

extension FlutrisPointListFromJson on List<Map<String, dynamic>> {
  List<FlutrisPoint> toFlutrisPoints() {
    return map(FlutrisPoint.fromJson).toList();
  }
}
