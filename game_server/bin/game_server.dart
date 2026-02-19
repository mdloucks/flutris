import 'package:core/core.dart';
import 'package:game_server/layout_engine_interface.dart';

void main() async {
  final uri = Uri(
    scheme: 'http',
    host: 'localhost',
    port: CoreConstants.layoutEnginePort,
  );
  final blockLayout = runWidget(widget: Tetrominos.block, uri: uri);
  print(await blockLayout);
}
