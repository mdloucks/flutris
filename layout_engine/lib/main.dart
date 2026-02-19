import 'package:core/core.dart';
import 'package:flutris/features/layout_validation/layout_probe.dart';
import 'package:flutris/features/layout_validation/worker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:logging/logging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final worker = Worker();
  worker.spawn();

  // TODO: this is a pretty messy implementation. Gives me callback hell vibes.
  // It's hard because I don't want to spawn the server inside the MainApp widget,
  // because I'm concerned widget lifecycle weirdness will impact it.
  final viewModel = MainViewModel(
    onMeasuredFunction: () => [],
    onOnMeasuredFunctionChanged: (onMeasuredFunction) {
      worker.onMeasured = onMeasuredFunction;
    },
  );

  runApp(LayoutProbeContainer(viewModel));
}

class MainViewModel extends ChangeNotifier {
  String? userEnteredWidget;
  OnMeasuredFunction onMeasuredFunction;
  final Function(OnMeasuredFunction) onOnMeasuredFunctionChanged;

  MainViewModel({
    this.userEnteredWidget,
    required this.onMeasuredFunction,
    required this.onOnMeasuredFunctionChanged,
  });

  /// Once we're done measuring, we need to update this method to return
  /// the correct data.
  void updateOnMeasuredFunction(OnMeasuredFunction onMeasuredFunction) {
    this.onMeasuredFunction = onMeasuredFunction;
    onOnMeasuredFunctionChanged(onMeasuredFunction);
  }
}

class LayoutProbeContainer extends StatelessWidget {
  static const kBoardWidth = 100.0;
  static const kBoardHeight = 100.0;

  static final Logger _log = Logger('LayoutProbeContainer');

  final MainViewModel viewModel;

  LayoutProbeContainer(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LayoutProbe(
            scale: 20,
            grid: const GridLayout(rows: 20, cols: 8),
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, widget) {
                return UserRenderedWidget(
                  block: Tetrominos.block,
                  blockScale: 2,
                  // Here we pass the user widget String. This will cause a rebuild,
                  // which triggers the onMeasured function, which will send the data
                  // back to the server isolate, which will return a OK/ERR back to
                  // the consumer.
                  userEnteredWidget:
                      viewModel.userEnteredWidget ?? Tetrominos.tetrisT,
                );
              },
            ),
            onMeasured: (blocks) {
              _log.fine('Layout measured');
              _log.finer(viewModel.userEnteredWidget);
              _log.finer(blocks);
              viewModel.updateOnMeasuredFunction(() => blocks);
            },
          ),
        ),
      ),
    );
  }
}

class UserRenderedWidget extends StatelessWidget {
  final String block;
  final String userEnteredWidget;
  final double blockScale;
  const UserRenderedWidget({
    super.key,
    required this.block,
    required this.blockScale,
    required this.userEnteredWidget,
  });

  @override
  Widget build(BuildContext context) {
    return EvalWidget(
      packages: {
        'example': {
          'main.dart':
              '''
import 'package:flutter/material.dart';

$block

$userEnteredWidget

''',
        },
      },
      assetPath: 'program.evc',
      library: 'package:example/main.dart',
      function: 'UserEnteredWidget.', // constructor
      args: const [],
    );
  }
}
