import 'dart:convert';

import 'package:core/core.dart';
import 'package:core/src/data/models/websocket/envelope.dart';
import 'package:core/src/data/models/websocket/message_type.dart';

// TODO: separate this into server/client types so in the sealed hierarchy, the
// client won't have to handle server stuff and vice versa.
sealed class WsMessage {
  const WsMessage();

  factory WsMessage.fromEnvelope(WsEnvelope envelope) {
    final json = jsonDecode(envelope.message) as Map<String, dynamic>;
    return switch (envelope.type) {
      MessageType.validateLayout => WsMessageValidateLayout.fromJson(json),
      MessageType.userEnteredWidget => WsMessageUserEnteredWidget.fromJson(
        json,
      ),
    };
  }
}

class WsMessageUserEnteredWidget extends WsMessage {
  final String userEnteredWidget;

  WsMessageUserEnteredWidget({required this.userEnteredWidget});

  factory WsMessageUserEnteredWidget.fromJson(Map<String, dynamic> json) {
    return WsMessageUserEnteredWidget(
      userEnteredWidget: json['userEnteredWidget'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'userEnteredWidget': userEnteredWidget};
  }
}

class WsMessageValidateLayout extends WsMessage {
  final List<FlutrisPoint> points;

  bool get isLayoutValid => !points.any((point) => !point.isValid);

  WsMessageValidateLayout({required this.points});

  factory WsMessageValidateLayout.fromJson(Map<String, dynamic> json) {
    final raw = json['points'];
    if (raw is! List) {
      throw FormatException('"points" must be a List');
    }

    final points = raw
        .map((e) => FlutrisPoint.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);

    return WsMessageValidateLayout(points: points);
  }

  Map<String, dynamic> toJson() {
    return {'points': points.map((e) => e.toJson()).toList()};
  }
}
