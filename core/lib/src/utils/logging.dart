import 'package:logging/logging.dart';

class CoreLoggers {
  static final Logger client = Logger('client');
  static final Logger gameServer = Logger('gameServer');
  static final Logger layoutEngine = Logger('layoutEngine');
  static final Logger core = Logger('core');
  static void init() {
    hierarchicalLoggingEnabled = true;
    // TODO: set this via a dart define flag
    Logger.root.level = Level.ALL;
    client.onRecord.listen((record) {
      print('[CLIENT] ${record.message}');
    });
    gameServer.onRecord.listen((record) {
      print('[gameServer] ${record.message}');
    });
    layoutEngine.onRecord.listen((record) {
      print('[layoutEngine] ${record.message}');
    });
    core.onRecord.listen((record) {
      print('[core] ${record.message}');
    });

    core.info("Initialized CoreLoggers");
  }
}
