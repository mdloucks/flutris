import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:game_server/layout_engine_interface.dart';

Future<void> runServer() async {
  final layoutEngineUri = Uri(
    scheme: 'http',
    host: 'localhost',
    port: CoreConstants.layoutEnginePort,
  );

  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    CoreConstants.websocketPort,
  );

  await for (final req in server) {
    if (!WebSocketTransformer.isUpgradeRequest(req)) {
      req.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.text
        ..write('WebSocket only')
        ..close();
      continue;
    }

    final ws = await WebSocketTransformer.upgrade(req);

    ws.listen((message) async {
      try {
        final widget = message is String
            ? message
            : utf8.decode(message as List<int>);
        final points = await runWidget(widget: widget, uri: layoutEngineUri);
        ws.add(jsonEncode(points.map((p) => p.toJson()).toList()));
      } catch (e) {
        ws.add(jsonEncode({'error': e.toString()}));
      }
    });
  }
}
