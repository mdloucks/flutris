import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const LayoutTestWidget(),
    );
  }
}

class LayoutTestWidget extends StatefulWidget {
  const LayoutTestWidget({super.key});

  @override
  State<LayoutTestWidget> createState() => _LayoutTestWidgetState();
}

class _LayoutTestWidgetState extends State<LayoutTestWidget> {
  WebSocketChannel? _channel;
  String _lastResponse = '';

  void _connectAndSend() {
    final uri = Uri.parse('ws://localhost:${CoreConstants.websocketPort}');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        debugPrint('Received: $message');
        setState(() {
          _lastResponse = message.toString();
        });
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
      },
      onDone: () {
        debugPrint('WebSocket closed');
      },
    );

    const mockPayload = {
      "layout": {
        "index": 0,
        "centerOnBoard": {"dx": 40.0, "dy": 20.0},
        "topLeftOnBoard": {"dx": 30.0, "dy": 10.0},
        "size": {"width": 20.0, "height": 20.0},
        "cell": {"x": 2, "y": 1},
      },
      "isValid": true,
    };

    _channel!.sink.add(jsonEncode(mockPayload));
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _connectAndSend,
          child: const Text('Send Layout'),
        ),
        const SizedBox(height: 16),
        Text(
          _lastResponse.isEmpty ? 'No response yet' : _lastResponse,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
