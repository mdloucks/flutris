import 'dart:math';

import 'package:flutter/material.dart';

class GridLayout {
  final int rows;
  final int cols;

  const GridLayout({required this.rows, required this.cols});
}

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
}

/// New result type: includes the measured block info plus a validity flag.
class FlutrisPoint {
  final BlockLayout layout;
  final bool isValid; // true = perfectly aligned, false = ambiguous/error

  const FlutrisPoint({required this.layout, required this.isValid});

  FlutrisPoint copyWith({BlockLayout? layout, bool? isValid}) {
    return FlutrisPoint(
      layout: layout ?? this.layout,
      isValid: isValid ?? this.isValid,
    );
  }
}

class LayoutProbe extends StatefulWidget {
  final Widget child;
  final GridLayout grid;
  final double scale;
  final void Function(List<FlutrisPoint> blocks) onMeasured;

  const LayoutProbe({
    super.key,
    required this.child,
    required this.grid,
    required this.onMeasured,
    this.scale = 20,
  });

  @override
  State<LayoutProbe> createState() => _LayoutProbeState();
}

class _LayoutProbeState extends State<LayoutProbe> {
  bool _didReport = false;
  List<FlutrisPoint> _lastPoints = const [];

  double get _boardWidth => widget.grid.cols * widget.scale;
  double get _boardHeight => widget.grid.rows * widget.scale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant LayoutProbe oldWidget) {
    super.didUpdateWidget(oldWidget);

    final gridChanged =
        oldWidget.grid.rows != widget.grid.rows ||
        oldWidget.grid.cols != widget.grid.cols;

    final scaleChanged = oldWidget.scale != widget.scale;

    if (gridChanged || scaleChanged || oldWidget.child != widget.child) {
      _didReport = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    if (!mounted || _didReport) return;

    final rows = widget.grid.rows;
    final cols = widget.grid.cols;

    if (rows <= 0 || cols <= 0 || widget.scale <= 0) {
      _lastPoints = const [];
      widget.onMeasured(_lastPoints);
      _didReport = true;
      setState(() {});
      return;
    }

    final cellW = widget.scale;
    final cellH = widget.scale;

    final blockElements = <Element>[];
    void visit(Element e) {
      // detect Containers as blocks (same heuristic you had); adjust as needed
      if (e.widget is Container) blockElements.add(e);
      e.visitChildren(visit);
    }

    context.visitChildElements(visit);

    final boardBox = context.findRenderObject() as RenderBox;
    final boardOriginGlobal = boardBox.localToGlobal(Offset.zero);

    int toCol(double x) {
      final v = (x / cellW).floor();
      if (v < 0) return 0;
      if (v >= cols) return cols - 1;
      return v;
    }

    int toRow(double y) {
      final v = (y / cellH).floor();
      if (v < 0) return 0;
      if (v >= rows) return rows - 1;
      return v;
    }

    final layouts = <BlockLayout>[];
    for (var i = 0; i < blockElements.length; i++) {
      final render = blockElements[i].renderObject;
      if (render is! RenderBox) continue; // skip if not layout box

      final box = render as RenderBox;
      final topLeftGlobal = box.localToGlobal(Offset.zero);
      final size = box.size;
      final centerGlobal = topLeftGlobal + size.center(Offset.zero);

      final topLeftOnBoard = topLeftGlobal - boardOriginGlobal;
      final centerOnBoard = centerGlobal - boardOriginGlobal;

      final cell = Point<int>(toCol(centerOnBoard.dx), toRow(centerOnBoard.dy));

      layouts.add(
        BlockLayout(
          index: i,
          centerOnBoard: centerOnBoard,
          topLeftOnBoard: topLeftOnBoard,
          size: size,
          cell: cell,
        ),
      );
    }

    // Determine validity per layout
    const double tolerance = 0.001; // strict tolerance for "perfect" centering

    // Start with all valid, then mark invalid where rules fail.
    final points = List<FlutrisPoint>.generate(
      layouts.length,
      (i) => FlutrisPoint(layout: layouts[i], isValid: true),
    );

    // 1) Check center inside expected center with tolerance
    for (var i = 0; i < layouts.length; i++) {
      final r = layouts[i];
      final expectedCenterX = (r.cell.x + 0.5) * cellW;
      final expectedCenterY = (r.cell.y + 0.5) * cellH;

      final dx = (r.centerOnBoard.dx - expectedCenterX).abs();
      final dy = (r.centerOnBoard.dy - expectedCenterY).abs();

      if (dx > tolerance || dy > tolerance) {
        points[i] = points[i].copyWith(isValid: false);
      }
    }

    // 2) Find duplicates (multiple blocks mapped to same cell) and mark all in that cell invalid
    final Map<Point<int>, List<int>> cellToIndices = {};
    for (var i = 0; i < layouts.length; i++) {
      cellToIndices.putIfAbsent(layouts[i].cell, () => []).add(i);
    }
    for (final entry in cellToIndices.entries) {
      final indices = entry.value;
      if (indices.length > 1) {
        for (final idx in indices) {
          points[idx] = points[idx].copyWith(isValid: false);
        }
      }
    }

    // 3) If any layout size doesn't match cell size exactly, mark invalid (optional strictness)
    for (var i = 0; i < layouts.length; i++) {
      final r = layouts[i];
      if ((r.size.width - cellW).abs() > tolerance ||
          (r.size.height - cellH).abs() > tolerance) {
        points[i] = points[i].copyWith(isValid: false);
      }
    }

    // Save last points (for painting) and report via callback
    _lastPoints = List.unmodifiable(points);
    _didReport = true;
    widget.onMeasured(_lastPoints);

    // trigger repaint so painter can draw red/green markers
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _boardWidth,
      height: _boardHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          IgnorePointer(
            child: CustomPaint(
              painter: _GridPainter(
                rows: widget.grid.rows,
                cols: widget.grid.cols,
                points: _lastPoints,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<FlutrisPoint> points;

  _GridPainter({
    required this.rows,
    required this.cols,
    this.points = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rows <= 0 || cols <= 0) return;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black;

    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (var c = 0; c <= cols; c++) {
      final x = c * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), strokePaint);
    }

    for (var r = 0; r <= rows; r++) {
      final y = r * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), strokePaint);
    }

    // draw measured points (center markers), green if valid, red if invalid
    for (final p in points) {
      final center = p.layout.centerOnBoard;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = p.isValid
            ? Colors.green.withOpacity(0.7)
            : Colors.red.withOpacity(0.8);
      final radius = min(cellW, cellH) * 0.25;
      canvas.drawCircle(center, radius, paint);

      // optional outline
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black;
      canvas.drawCircle(center, radius, outline);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        !_listEquals(oldDelegate.points, points);
  }

  // simple list equality for points
  bool _listEquals(List<FlutrisPoint> a, List<FlutrisPoint> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.layout.index != y.layout.index ||
          x.layout.cell != y.layout.cell ||
          x.isValid != y.isValid ||
          x.layout.centerOnBoard != y.layout.centerOnBoard)
        return false;
    }
    return true;
  }
}
