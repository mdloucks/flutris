import 'dart:convert';
import 'dart:io';

Future<BlockLayout> runWidget<BlockLayout>({
  required String widget,
  required Uri uri,
}) async {
  if (widget.length > 1000) throw ArgumentError('>1000 chars');
  if (RegExp(r'\bimport\b').hasMatch(widget)) {
    throw ArgumentError('import not allowed');
  }
  final c = HttpClient();
  try {
    final req = await c.postUrl(uri);
    req.headers.contentType = ContentType('text', 'plain', charset: 'utf-8');
    req.add(utf8.encode(widget));
    final res = await req.close();
    final body = await utf8.decodeStream(res);
    final fixed = body.replaceAllMapped(
      RegExp(r'([{\[,]\s*)([A-Za-z_]\w*)\s*:'),
      (m) => '${m[1]}"${m[2]}":',
    );
    return BlockLayout.fromJson(jsonDecode(fixed));
  } finally {
    c.close();
  }
}
