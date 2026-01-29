// Canonical Tetris pieces as Dart string literals. Each assumes a `Block` widget
// exists in scope (as you provided). Use these strings as the `main.dart`
// content for quick testing in your EvalWidget harness.

class Tetrominos {
  static const tetrisI = '''
class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // horizontal I (4 long)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Block(), Block(), Block(), Block(),
      ],
    );
  }
}
''';

  static const tetrisIVertical = '''

class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // vertical I (4 tall)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Block(), Block(), Block(), Block(),
      ],
    );
  }
}
''';

  static const tetrisO = '''

class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // O (2x2 square)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [Block(), Block()]),
        Row(mainAxisSize: MainAxisSize.min, children: [Block(), Block()]),
      ],
    );
  }
}
''';

  static const tetrisT = '''

class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // T shape:
    //  _X_
    //  XXX
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [SizedBox(width:20), Block(), SizedBox(width:20)],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [Block(), Block(), Block()],
        ),
      ],
    );
  }
}
''';

  static const tetrisS = '''

class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // S shape:
    //  _XX
    //  XX_
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width:20), Block(), Block()]),
        Row(mainAxisSize: MainAxisSize.min, children: [Block(), Block(), SizedBox(width:20)]),
      ],
    );
  }
}
''';

  static const tetrisZ = '''

class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // Z shape:
    //  XX_
    //  _XX
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [Block(), Block(), SizedBox(width:20)]),
        Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width:20), Block(), Block()]),
      ],
    );
  }
}
''';

  static const tetrisJ = '''

class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // J shape (like an L mirrored)
    //  X_
    //  XXX
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [Block(), SizedBox(width:20), SizedBox(width:20)]),
        Row(mainAxisSize: MainAxisSize.min, children: [Block(), Block(), Block()]),
      ],
    );
  }
}
''';

  static const tetrisL = '''

class UserEnteredWidget extends StatelessWidget {
  const UserEnteredWidget();

  @override
  Widget build(BuildContext context) {
    // L shape
    //  _X
    //  XXX
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width:20), SizedBox(width:20), Block()]),
        Row(mainAxisSize: MainAxisSize.min, children: [Block(), Block(), Block()]),
      ],
    );
  }
}
''';
}
