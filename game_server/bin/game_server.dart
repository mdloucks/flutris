import 'package:game_server/game_server.dart' as game_server;
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('hi');
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse('http://localhost:8080'));
  request.headers.set(
    HttpHeaders.contentTypeHeader,
    'text/plain; charset=utf-8',
  );

  request.add(
    utf8.encode('''
class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Block(), Block(), Block(), Block(),
      ],
    );
  }
}
'''),
  );

  print('wow');
  final response = await request.close();
  final body = await utf8.decodeStream(response);
  print('resp');
  print(response);
  stdout.writeln(body);

  client.close();
}
