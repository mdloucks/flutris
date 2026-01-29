import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutris/main.dart';

void main() {
  testWidgets('calculate real position', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    final finder = find.byType(Container);
    expect(finder, findsNWidgets(4)); // verify count

    for (var i = 0; i < finder.evaluate().length; i++) {
      final hit = finder.at(i);

      // Logical (device-independent) center:
      final center = tester.getCenter(hit);
      print('center $i = $center');

      // Or full rect in logical coords:
      final rect = tester.getRect(hit);
      print('rect $i = $rect');

      // If you need a RenderBox for more control:
      final element = finder.evaluate().elementAt(i);
      final renderBox = element.renderObject as RenderBox;
      final topLeftGlobal = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      print('topLeftGlobal $i = $topLeftGlobal size $size');
    }
  });
}
