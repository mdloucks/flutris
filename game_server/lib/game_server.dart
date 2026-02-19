import 'dart:convert';
import 'dart:io';

Future<void> main() async {
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

  final response = await request.close();
  print("response");
  print(response);
  await response.drain();
  client.close();
}
