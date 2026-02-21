import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class GameServerService {
  Future<void> connect({
    required Uri uri,
    required void Function(WsMessage data) onData,
    required void Function(Object error) onError,
    void Function()? onDone,
  });

  void sendEnvelope(WsEnvelope envelope);

  Future<void> disconnect();
}

class GameServerServiceWebsocket implements GameServerService {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  /// Connect to our backend service and receive websocket events
  ///
  /// It's the duty of the service layer to take these raw 'envelope'
  /// packets and unwrap them into domain-friendly types that have
  /// semantic meaning in our app.
  Future<void> connect({
    required Uri uri,
    required void Function(WsMessage data) onData,
    required void Function(Object error) onError,
    void Function()? onDone,
  }) async {
    await disconnect();

    _channel = WebSocketChannel.connect(uri);
    _sub = _channel!.stream.listen(
      (websocketJson) {
        try {
          final data = jsonDecode(websocketJson.toString());

          final envelope = WsEnvelope.fromJson(data);
          final message = WsMessage.fromEnvelope(envelope);

          onData(message);
          CoreLoggers.client.finer(
            'Received response from server $message ${envelope.type}',
          );
        } catch (e) {
          CoreLoggers.client.severe(
            'Websocket error ${e.toString()} ${StackTrace.current}',
          );
          onError(e);
        }
      },
      onError: (e) => onError(e),
      onDone: onDone,
    );
  }

  void sendEnvelope(WsEnvelope envelope) {
    CoreLoggers.client.finer('Sending payload to game server $envelope');
    final ch = _channel;
    if (ch == null) return;
    ch.sink.add(jsonEncode(envelope.toJson()));
  }

  Future<void> disconnect() async {
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
    CoreLoggers.client.info('Websocket disconnected');
  }
}
