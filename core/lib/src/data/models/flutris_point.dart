import 'package:core/core.dart';

/// A block on the board. It has a layout (which may or may not be valid)
class FlutrisPoint {
  final BlockLayout layout;
  final bool isValid;

  const FlutrisPoint({required this.layout, required this.isValid});

  FlutrisPoint copyWith({BlockLayout? layout, bool? isValid}) {
    return FlutrisPoint(
      layout: layout ?? this.layout,
      isValid: isValid ?? this.isValid,
    );
  }

  Map<String, dynamic> toJson() {
    return {'layout': layout.toJson(), 'isValid': isValid};
  }

  factory FlutrisPoint.fromJson(Map<String, dynamic> json) {
    return FlutrisPoint(
      layout: BlockLayout.fromJson(json['layout']),
      isValid: json['isValid'] as bool,
    );
  }

  @override
  String toString() {
    return 'FlutrisPoint('
        'index: ${layout.index}, '
        'cell: (${layout.cell.x}, ${layout.cell.y}), '
        'center: (${layout.centerDx}, ${layout.centerDy}), '
        'size: (${layout.width}x${layout.height}), '
        'isValid: $isValid'
        ')';
  }
}

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
