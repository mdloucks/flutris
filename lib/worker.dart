import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// Helper class for long lived Dart isolates
///
/// Writing this out in my own words to help me remember it better.
/// Long lived isolates, also known as 'background workers' offer a
/// benefit over isolates spawned via Isolate.run by avoiding the pentalty
/// incurred during Isolate startup. In order to communicate with the isolate
/// though, you must pass in a ReceivePort object. This ReceivePort will...
/// receive data. Yes, mindblowing. the ReceivePort object has a send()
/// function you may call within the isolate.

typedef OnMeasuredFunction = String Function();

class Worker {
  late final SendPort _sendToIsolate;
  OnMeasuredFunction onMeasured = () => '{}';

  void spawn({required Function(String) onData}) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      // Here, we're sending the receive port "into" the isolate.
      // This way, when the isolate receives a request, it can send that
      // to the main isolate where Flutter can interpret it.
      (SendPort port) async {
        // once the isolate starts up, we want to send back to the main Flutter
        // isolate a port. That way they can send the server messages. We
        // can already send them messages with the SendPort they pass in.
        final replyPort = ReceivePort();
        port.send(replyPort.sendPort);

        // Start an isolate that returns requests for grid validation
        var server = await HttpServer.bind(InternetAddress.anyIPv6, 8080);
        await server.forEach((HttpRequest request) async {
          final body = await utf8.decoder.bind(request).join();

          port.send(body);

          replyPort.listen((data) {
            print("data from main isolate: $data");
            // TODO: return success or not based on layout
            // NOTE: might have to attach an id with this and do more work around async
            // to avoid race conditions. Especially with multiple clients.
            request.response.write(data);
            request.response.close();
          });
        });
      },
      receivePort.sendPort,
    );

    receivePort.listen((data) {
      if (data is SendPort) {
        _sendToIsolate = data;
        return;
      }
      // here we got a request from the web server, so now we
      // interperet it with flutter and then send the resp back
      print("data from http server isolate $data");
      final measuredData = onMeasured();
      print("data from flutter layout probe func $measuredData");
      _sendToIsolate.send(measuredData);
    });
  }
}

// Use this to send data to server
/*

curl -X POST http://localhost:8080 \
  -H "Content-Type: text/plain; charset=utf-8" \
  --data-binary @- <<'EOF'
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
EOF

*/
