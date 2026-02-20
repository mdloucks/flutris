import 'dart:math';

import 'package:client/features/layout/data/services/layout_service.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class LayoutTestWidget extends StatefulWidget {
  const LayoutTestWidget({super.key});

  @override
  State<LayoutTestWidget> createState() => _LayoutTestWidgetState();
}

class _LayoutTestWidgetState extends State<LayoutTestWidget> {
  final _ds = LayoutServiceWebsocket();

  List<FlutrisPoint> _points = const [];
  String _lastError = '';

  final GridLayoutModel _grid = const GridLayoutModel(rows: 20, cols: 8);
  final double _scale = 20;

  @override
  void dispose() {
    _ds.disconnect();
    super.dispose();
  }

  Future<void> _sendMock() async {
    final uri = Uri.parse('ws://localhost:${CoreConstants.websocketPort}');

    await _ds.connect(
      uri: uri,
      onPoints: (points) {
        if (!mounted) return;
        setState(() {
          _points = points;
          _lastError = '';
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _lastError = e.toString();
        });
      },
    );

    final mockPayload = {
      'grid': _grid.toJson(),
      'layout': {
        'index': 0,
        'centerOnBoard': {'dx': 40.0, 'dy': 20.0},
        'topLeftOnBoard': {'dx': 30.0, 'dy': 10.0},
        'size': {'width': 20.0, 'height': 20.0},
        'cell': {'x': 2, 'y': 1},
      },
      'isValid': true,
    };

    _ds.sendJson(mockPayload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutGrid(grid: _grid, scale: _scale, points: _points),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendMock,
              child: const Text('Send Layout'),
            ),
            const SizedBox(height: 12),
            if (_lastError.isNotEmpty)
              Text(_lastError, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Model: layout for the game grid
class GridLayoutModel {
  final int rows;
  final int cols;

  const GridLayoutModel({required this.rows, required this.cols});

  Map<String, dynamic> toJson() => {'rows': rows, 'cols': cols};

  factory GridLayoutModel.fromJson(Map<String, dynamic> json) {
    return GridLayoutModel(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
    );
  }
}

/// Widget: draws the grid and points
class LayoutGrid extends StatefulWidget {
  final GridLayoutModel grid;
  final double scale;
  final List<FlutrisPoint> points;

  const LayoutGrid({
    super.key,
    required this.grid,
    required this.points,
    this.scale = 20,
  });

  @override
  State<LayoutGrid> createState() => _LayoutGridState();
}

class _LayoutGridState extends State<LayoutGrid> {
  double get _boardWidth => widget.grid.cols * widget.scale;
  double get _boardHeight => widget.grid.rows * widget.scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _boardWidth,
      height: _boardHeight,
      child: CustomPaint(
        painter: _GridPainter(
          rows: widget.grid.rows,
          cols: widget.grid.cols,
          points: widget.points,
        ),
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

    for (final p in points) {
      final center = Offset(p.layout.centerDx, p.layout.centerDy);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = p.isValid
            ? Colors.green.withOpacity(0.7)
            : Colors.red.withOpacity(0.8);

      final radius = min(cellW, cellH) * 0.25;
      canvas.drawCircle(center, radius, paint);

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

  bool _listEquals(List<FlutrisPoint> a, List<FlutrisPoint> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.layout.index != y.layout.index ||
          x.layout.cell != y.layout.cell ||
          x.isValid != y.isValid ||
          x.layout.centerDx != y.layout.centerDx ||
          x.layout.centerDy != y.layout.centerDy) {
        return false;
      }
    }
    return true;
  }
}
