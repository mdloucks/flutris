import 'dart:math';

import 'package:flutter/material.dart';

class BlockLayout {
  final int index;
  final Offset centerOnBoard;
  final Offset topLeftOnBoard;
  final Size size;
  final Point<int> cell;

  const BlockLayout({
    required this.index,
    required this.centerOnBoard,
    required this.topLeftOnBoard,
    required this.size,
    required this.cell,
  });

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'centerOnBoard': {'dx': centerOnBoard.dx, 'dy': centerOnBoard.dy},
      'topLeftOnBoard': {'dx': topLeftOnBoard.dx, 'dy': topLeftOnBoard.dy},
      'size': {'width': size.width, 'height': size.height},
      'cell': {'x': cell.x, 'y': cell.y},
    };
  }

  factory BlockLayout.fromJson(Map<String, dynamic> json) {
    return BlockLayout(
      index: json['index'] as int,
      centerOnBoard: Offset(
        (json['centerOnBoard']['dx'] as num).toDouble(),
        (json['centerOnBoard']['dy'] as num).toDouble(),
      ),
      topLeftOnBoard: Offset(
        (json['topLeftOnBoard']['dx'] as num).toDouble(),
        (json['topLeftOnBoard']['dy'] as num).toDouble(),
      ),
      size: Size(
        (json['size']['width'] as num).toDouble(),
        (json['size']['height'] as num).toDouble(),
      ),
      cell: Point<int>(json['cell']['x'] as int, json['cell']['y'] as int),
    );
  }
}
