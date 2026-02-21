import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:game_server/layout_engine_interface.dart';
import 'package:uuid/uuid.dart';

Future<void> runServer() async {
  CoreLoggers.init();

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

    ws.listen((websocketEvent) async {
      try {
        final json = jsonDecode(websocketEvent);
        final envelope = WsEnvelope.fromJson(json);
        final message = WsMessage.fromEnvelope(envelope);

        CoreLoggers.gameServer.fine(
          "Received request ${envelope.id} ${envelope.version} ${envelope.type}",
        );

        switch (message) {
          case WsMessageUserEnteredWidget():
            final points = await runWidget(
              widget: message.userEnteredWidget,
              uri: layoutEngineUri,
            );

            final userEnteredWidgetMessage = WsMessageValidateLayout(
              points: points,
            );
            final uuid = Uuid();
            final envelope = WsEnvelope(
              version: 0,
              type: MessageType.validateLayout,
              message: jsonEncode(userEnteredWidgetMessage),
              id: uuid.v4(),
            );
            CoreLoggers.gameServer.fine(
              "Sending envelope to client ${envelope.id}",
            );

            ws.add(jsonEncode(envelope.toJson()));
          case WsMessageValidateLayout():
            print('messagevalidatelayout');
            throw UnimplementedError();
        }
      } catch (e) {
        CoreLoggers.gameServer.severe(
          "Error when parsing request from client",
          e,
        );
        // ws.add(jsonEncode({'error': e.toString()}));
      }
    });
  }
}
