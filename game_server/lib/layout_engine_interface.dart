import 'dart:convert';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;

Future<List<FlutrisPoint>> runWidget({
  required String widget,
  required Uri uri,
}) async {
  final resp = await http.post(
    uri,
    headers: {'Content-Type': 'text/plain; charset=utf-8'},
    body: utf8.encode(widget),
  );
  final body = resp.body;
  final fixed = body.replaceAllMapped(
    RegExp(r'([{\[,]\s*)([A-Za-z_]\w*)\s*:'),
    (m) => '${m[1]}"${m[2]}":',
  );
  final decoded = jsonDecode(fixed);
  if (decoded is! List)
    throw FormatException(
      'Expected a JSON list but got ${decoded.runtimeType}',
    );
  return decoded
      .cast<dynamic>()
      .map((e) => FlutrisPoint.fromJson((e as Map).cast<String, dynamic>()))
      .toList(growable: false);
}
