import 'dart:math';

class BlockLayout {
  final int index;

  final double centerDx;
  final double centerDy;

  final double topLeftDx;
  final double topLeftDy;

  final double width;
  final double height;

  final Point<int> cell;

  const BlockLayout({
    required this.index,
    required this.centerDx,
    required this.centerDy,
    required this.topLeftDx,
    required this.topLeftDy,
    required this.width,
    required this.height,
    required this.cell,
  });

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'centerOnBoard': {'dx': centerDx, 'dy': centerDy},
      'topLeftOnBoard': {'dx': topLeftDx, 'dy': topLeftDy},
      'size': {'width': width, 'height': height},
      'cell': {'x': cell.x, 'y': cell.y},
    };
  }

  factory BlockLayout.fromJson(Map<String, dynamic> json) {
    final center = json['centerOnBoard'] as Map<String, dynamic>;
    final topLeft = json['topLeftOnBoard'] as Map<String, dynamic>;
    final size = json['size'] as Map<String, dynamic>;
    final cell = json['cell'] as Map<String, dynamic>;

    return BlockLayout(
      index: json['index'] as int,
      centerDx: (center['dx'] as num).toDouble(),
      centerDy: (center['dy'] as num).toDouble(),
      topLeftDx: (topLeft['dx'] as num).toDouble(),
      topLeftDy: (topLeft['dy'] as num).toDouble(),
      width: (size['width'] as num).toDouble(),
      height: (size['height'] as num).toDouble(),
      cell: Point<int>(cell['x'] as int, cell['y'] as int),
    );
  }
}
