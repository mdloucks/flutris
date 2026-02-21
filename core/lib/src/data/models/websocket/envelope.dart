import 'dart:convert';

import 'package:core/core.dart';
import 'package:core/src/data/models/websocket/message_type.dart';

class WsEnvelope {
  final int version;
  final MessageType type;
  // for traceability
  final String? id;
  final String message;

  WsEnvelope({
    required this.version,
    required this.type,
    required this.message,
    this.id,
  }) {
    try {
      jsonDecode(message);
    } on FormatException {
      CoreLoggers.core.severe("Could not parse JSON \n $message");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'type': type.name,
    'id': id,
    'message': message,
  };

  factory WsEnvelope.fromJson(Map<String, dynamic> json) {
    final type = MessageType.fromString(json['type']);

    if (type == null) {
      CoreLoggers.core.severe("Unexpected websocket type ${json['type']}");
      throw Exception('');
    }
    return WsEnvelope(
      version: json['version'] as int,
      type: type,
      id: json['id'] as String?,
      message: json['message'],
    );
  }

  @override
  String toString() {
    return 'WsEnvelope('
        'version: $version, '
        'type: $type, '
        'id: $id, '
        'message: $message'
        ')';
  }
}
