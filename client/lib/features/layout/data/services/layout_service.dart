import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class LayoutService {
  Future<void> connect({
    required Uri uri,
    required void Function(List<FlutrisPoint> points) onPoints,
    required void Function(Object error) onError,
    void Function()? onDone,
  });

  void sendJson(Object payload);

  Future<void> disconnect();
}

class LayoutServiceWebsocket implements LayoutService {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  Future<void> connect({
    required Uri uri,
    required void Function(List<FlutrisPoint> points) onPoints,
    required void Function(Object error) onError,
    void Function()? onDone,
  }) async {
    await disconnect();

    _channel = WebSocketChannel.connect(uri);
    _sub = _channel!.stream.listen(
      (message) {
        try {
          final raw = message.toString();
          final decoded = jsonDecode(raw);

          if (decoded is! List) {
            throw FormatException(
              'Expected a JSON list but got ${decoded.runtimeType}',
            );
          }

          final points = decoded
              .cast<dynamic>()
              .map(
                (e) =>
                    FlutrisPoint.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList(growable: false);

          onPoints(points);
        } catch (e) {
          onError(e);
        }
      },
      onError: (e) => onError(e),
      onDone: onDone,
    );
  }

  void sendJson(Object payload) {
    final ch = _channel;
    if (ch == null) return;
    ch.sink.add(jsonEncode(payload));
  }

  Future<void> disconnect() async {
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
  }
}
