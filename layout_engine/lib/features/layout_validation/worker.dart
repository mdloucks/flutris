import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutris/features/layout_validation/extensions.dart'
    show FlutrisPointListJson;
import 'package:flutris/features/layout_validation/layout_probe.dart';
import 'package:flutris/features/layout_validation/models/flutris_point.dart'
    show FlutrisPoint;
import 'package:logging/logging.dart';

/// Helper class for long lived Dart isolates
///
/// Writing this out in my own words to help me remember it better.
/// Long lived isolates, also known as 'background workers' offer a
/// benefit over isolates spawned via Isolate.run by avoiding the pentalty
/// incurred during Isolate startup. In order to communicate with the isolate
/// though, you must pass in a ReceivePort object. This ReceivePort will...
/// receive data. Yes, mindblowing. the ReceivePort object has a send()
/// function you may call within the isolate.

typedef OnMeasuredFunction = List<FlutrisPoint> Function();

class Worker {
  static final Logger _log = Logger('Worker');

  late final SendPort _sendToIsolate;
  OnMeasuredFunction onMeasured = () => [];

  void spawn() async {
    _log.info('Spawning worker isolate');

    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      // Here, we're sending the receive port "into" the isolate.
      // This way, when the isolate receives a request, it can send that
      // to the main isolate where Flutter can interpret it.
      (SendPort sendPort) async {
        _log.info('Worker isolate started');

        // once the isolate starts up, we want to send back to the main Flutter
        // isolate a port. That way they can send the server messages. We
        // can already send them messages with the SendPort they pass in.
        final replyPort = ReceivePort();
        sendPort.send(replyPort.sendPort);

        dynamic serverData;
        HttpRequest? serverRequest;

        void onRequestReceived(HttpRequest? request) {
          if (request == null) {
            _log.warning('Could not fulfill request, null data');
          } else {
            _log.fine('Sending response to HTTP client: $serverData');
          }
          // TODO: return success or not based on layout
          // NOTE: might have to attach an id with this and do more work around async
          // to avoid race conditions. Especially with multiple clients.
          //
          // Right now, the way it works is that when we receive a request to this server,
          // we set the onMeasured function to return whatever the Flutter process determines
          // is the layout. If we get a second request during that time, it may be possible
          // that it will be overriden.
          request?.response.write(serverData);
          request?.response.close();
        }

        replyPort.listen((data) {
          _log.fine('Received data from main isolate');
          serverData = data;
          if (serverRequest != null) {
            onRequestReceived(serverRequest);
          }
        });

        // Start an isolate that returns handles grid validation
        try {
          var server = await HttpServer.bind(InternetAddress.anyIPv6, 8080);
          _log.info('HTTP server bound on port 8080');

          await server.forEach((HttpRequest request) async {
            _log.fine('HTTP request received');
            final body = await utf8.decoder.bind(request).join();
            _log.finer('HTTP request body received');

            sendPort.send(body);
            serverRequest = request;
          });
        } catch (e, st) {
          _log.severe('Failed to start or run HTTP server', e, st);
        }
      },
      receivePort.sendPort,
    );

    receivePort.listen((data) {
      if (data is SendPort) {
        _log.info('Received SendPort from worker isolate');
        _sendToIsolate = data;
        return;
      }
      // here we got a request from the web server, so now we
      // interperet it with flutter and then send the resp back
      _log.fine('Received request data from HTTP server isolate');
      final measuredData = onMeasured();
      _log.finer('Measured layout data: $measuredData');
      _sendToIsolate.send(measuredData.toJson());
    });
  }
}

// Use this to send data to server
/*


VALID LAYOUT EXAMPLE

curl -X POST http://localhost:8080 \
  -H "Content-Type: text/plain; charset=utf-8" \
  --data-binary @- <<'EOF'
class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // vertical I (4 tall)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Block(), Block(), Block(), Block(),
      ],
    );
  }
}
EOF

INVALID LAYOUT EXAMPLE


curl -X POST http://localhost:8080 \
  -H "Content-Type: text/plain; charset=utf-8" \
  --data-binary @- <<'EOF'
class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // T shape:
    //  _X_
    //  XXX
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [SizedBox(width:20), Block(), SizedBox(width:20)],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [Block(), Block(), Block()],
        ),
      ],
    );
  }
}
EOF


*/

//   void spawn({required Function(String) onData}) async {
//     final receivePort = ReceivePort();
//     final isolate = await Isolate.spawn(
//       // Here, we're sending the receive port "into" the isolate.
//       // This way, when the isolate receives a request, it can send that
//       // to the main isolate where Flutter can interpret it.
//       (SendPort port) async {
//         // once the isolate starts up, we want to send back to the main Flutter
//         // isolate a port. That way they can send the server messages. We
//         // can already send them messages with the SendPort they pass in.
//         final replyPort = ReceivePort();
//         port.send(replyPort.sendPort);
//
//         final onSend = Function(HttpRequest request)
//
//         // Start an isolate that returns requests for grid validation
//         var server = await HttpServer.bind(InternetAddress.anyIPv6, 8080);
//         await server.forEach((HttpRequest request) async {
//           final body = await utf8.decoder.bind(request).join();
//
//           port.send(body);
//
//           replyPort.listen((data) {
//             print("data from main isolate: $data");
//             // TODO: return success or not based on layout
//             // NOTE: might have to attach an id with this and do more work around async
//             // to avoid race conditions. Especially with multiple clients.
//             request.response.write(data);
//             request.response.close();
//           });
//         });
//       },
//       receivePort.sendPort,
//     );
//
//     receivePort.listen((data) {
//       if (data is SendPort) {
//         _sendToIsolate = data;
//         return;
//       }
//       // here we got a request from the web server, so now we
//       // interperet it with flutter and then send the resp back
//       print("data from http server isolate $data");
//       final measuredData = onMeasured();
//       print("data from flutter layout probe func $measuredData");
//       _sendToIsolate.send(measuredData.toJson());
//     });
//   }
// }
//
// // Use this to send data to server
// /*
//
// curl -X POST http://localhost:8080 \
//   -H "Content-Type: text/plain; charset=utf-8" \
//   --data-binary @- <<'EOF'
// class UserEnteredWidget extends StatelessWidget {
//   const UserEnteredWidget();
//
//   @override
//   Widget build(BuildContext context) {
