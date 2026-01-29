import 'dart:io';
import 'dart:isolate';

import 'package:flutris/layout_probe.dart';
import 'package:flutris/tetrominos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';

void main() {
  // Start an isolate that returns requests for grid validation
  final isolate = Isolate.spawn((message) async {
    var server = await HttpServer.bind(InternetAddress.anyIPv6, 8080);
    await server.forEach((HttpRequest request) {
      request.response.write('Hello, world!');
      request.response.close();
    });
  }, "");

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const kBoardWidth = 100.0;
  static const kBoardHeight = 100.0;

  static const block = '''
class Block extends StatelessWidget {
  const Block({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(border: Border.all(), color: Colors.green),
    );
  }
}
  ''';

  // TODO: boilerplate until user sends us correct block
  static const userEnteredWidget = '''
class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(children: [Block(), Block(), Block()]),
        Column(children: [Block(), Block(), Block()]),
        Block(),
        Block(),
      ],
    );
  }
}
  ''';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LayoutProbe(
            scale: 20,
            grid: const GridLayout(rows: 20, cols: 8),
            child: UserRenderedWidget(
              block: block,
              blockScale: 2,
              userEnteredWidget: Tetrominos.tetrisIVertical,
            ),
            onMeasured: (blocks) {
              for (final b in blocks) {
                print(
                  'Block ${b.layout.index}: center=${b.layout.centerOnBoard} cell=${b.layout.cell}',
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class UserRenderedWidget extends StatelessWidget {
  final String block;
  final String userEnteredWidget;
  final double blockScale;
  const UserRenderedWidget({
    super.key,
    required this.block,
    required this.blockScale,
    required this.userEnteredWidget,
  });

  @override
  Widget build(BuildContext context) {
    return EvalWidget(
      packages: {
        'example': {
          'main.dart':
              '''
import 'package:flutter/material.dart';

$block

$userEnteredWidget

''',
        },
      },
      assetPath: 'program.evc',
      library: 'package:example/main.dart',
      function: 'UserEnteredWidget.', // constructor
      args: const [],
    );
  }
}
