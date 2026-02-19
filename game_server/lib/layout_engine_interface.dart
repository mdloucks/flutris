import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core/core.dart';

Future<List<MeasuredBlock>> runWidget({
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

    final decoded = jsonDecode(fixed);
    if (decoded is! List) {
      throw FormatException(
        'Expected a JSON list but got ${decoded.runtimeType}',
      );
    }

    return decoded
        .cast<dynamic>()
        .map((e) => MeasuredBlock.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
  } finally {
    c.close();
  }
}
