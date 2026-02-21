enum MessageType {
  // server -> client for returning the layout info
  validateLayout(key: 'validateLayout'),
  // client -> server for submtiting a user widget
  userEnteredWidget(key: 'userEnteredWidget');

  const MessageType({required this.key});

  final String key;

  static MessageType? fromString(String key) {
    for (final value in MessageType.values) {
      if (value.key == key) return value;
    }
    return null;
  }
}
