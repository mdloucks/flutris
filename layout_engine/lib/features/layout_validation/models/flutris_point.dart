import 'package:flutris/features/layout_validation/block_layout.dart';

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
}
