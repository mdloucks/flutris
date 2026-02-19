import 'package:core/core.dart';

class MeasuredBlock {
  final BlockLayout layout;
  final bool isValid;

  const MeasuredBlock({required this.layout, required this.isValid});

  Map<String, dynamic> toJson() => {
    'layout': layout.toJson(),
    'isValid': isValid,
  };

  factory MeasuredBlock.fromJson(Map<String, dynamic> json) {
    return MeasuredBlock(
      layout: BlockLayout.fromJson(
        (json['layout'] as Map).cast<String, dynamic>(),
      ),
      isValid: json['isValid'] as bool,
    );
  }

  @override
  String toString() {
    return 'MeasuredBlock('
        'index: ${layout.index}, '
        'cell: (${layout.cell.x}, ${layout.cell.y}), '
        'center: (${layout.centerDx}, ${layout.centerDy}), '
        'size: (${layout.width}x${layout.height}), '
        'isValid: $isValid'
        ')';
  }
}
