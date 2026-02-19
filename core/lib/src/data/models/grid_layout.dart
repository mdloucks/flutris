/// Layout for the game grid
class GridLayout {
  final int rows;
  final int cols;

  const GridLayout({required this.rows, required this.cols});

  Map<String, dynamic> toJson() {
    return {'rows': rows, 'cols': cols};
  }

  factory GridLayout.fromJson(Map<String, dynamic> json) {
    return GridLayout(rows: json['rows'] as int, cols: json['cols'] as int);
  }
}
