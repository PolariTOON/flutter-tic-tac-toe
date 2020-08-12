import 'package:flutter/material.dart'
    show
        BorderRadius,
        BoxConstraints,
        BuildContext,
        Color,
        Column,
        Container,
        CrossAxisAlignment,
        EdgeInsets,
        Expanded,
        MaterialApp,
        RawMaterialButton,
        RoundedRectangleBorder,
        Row,
        SafeArea,
        Scaffold,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextStyle,
        Widget,
        required,
        runApp;

final _title = 'Tic Tac Toe';
final _dark = Color(0xff333333);
final _light = Color(0xffffffff);

class _HistoryStep {
  final List<String> squares;
  final bool winner;

  const _HistoryStep(this.squares, this.winner);
}

class _StatusData {
  final int step;
  final bool winner;

  const _StatusData(this.step, this.winner);
}

class _BoardData {
  final List<String> squares;

  const _BoardData(this.squares);
}

class _GameData {
  int step;
  List<_HistoryStep> history;

  _GameData(this.step, this.history);
}

final int _size = 3;
final int _length = _size * _size;
final String _noPlayer = '';
final List<String> _players = ['O', 'X'];

int _calcSize() {
  return _size;
}

int _calcLength() {
  return _length;
}

String _calcNoPlayer() {
  return _noPlayer;
}

String _calcPlayer(int step) {
  return _players[step % _players.length];
}

bool _isWinner(List<String> squares, String player) {
  final int size = _calcSize();
  rows:
  for (int i = 0; i < size; ++i) {
    for (int j = 0; j < size; ++j) {
      if (squares[i * size + j] != player) {
        continue rows;
      }
    }
    return true;
  }
  columns:
  for (int i = 0; i < size; ++i) {
    for (int j = 0; j < size; ++j) {
      if (squares[j * size + i] != player) {
        continue columns;
      }
    }
    return true;
  }
  diagonals:
  for (int i = 0; i < 2; ++i) {
    for (int j = 0; j < size; ++j) {
      if (squares[(i + j) * (size + 1 - i * 2)] != player) {
        continue diagonals;
      }
    }
    return true;
  }
  return false;
}

class StatusParagraphText extends StatelessWidget {
  final String data;

  const StatusParagraphText(this.data);

  Widget build(BuildContext context) {
    return Text(
      this.data,
      style: TextStyle(
        color: _dark,
        height: 1.25,
        fontSize: 16,
      ),
    );
  }
}

class StatusParagraph extends StatelessWidget {
  final Widget child;

  const StatusParagraph({
    @required this.child,
  });

  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: this.child,
      ),
    );
  }
}

class StatusMenuButtonText extends StatelessWidget {
  final String data;

  const StatusMenuButtonText(this.data);

  Widget build(BuildContext context) {
    return Text(
      this.data,
      style: TextStyle(
        color: _light,
        height: 1.25,
        fontSize: 16,
      ),
    );
  }
}

class StatusMenuButton extends StatelessWidget {
  final Widget child;
  final void Function() onPressed;

  const StatusMenuButton({
    @required this.child,
    @required this.onPressed,
  });

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: RawMaterialButton(
        constraints: BoxConstraints(),
        padding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        fillColor: _dark,
        child: this.child,
        onPressed: this.onPressed,
      ),
    );
  }
}

class StatusMenu extends StatelessWidget {
  final List<Widget> children;

  const StatusMenu({
    this.children = const [],
  });

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: this.children,
      ),
    );
  }
}

class Status extends StatelessWidget {
  final _StatusData data;
  final void Function() clear;
  final void Function() undo;
  final void Function() redo;

  const Status(
    this.data, {
    @required this.clear,
    @required this.undo,
    @required this.redo,
  });

  Widget build(BuildContext context) {
    final _StatusData status = this.data;
    final int step = status.step;
    final bool winner = status.winner;
    final String text = winner
        ? 'Winner: ${_calcPlayer(step)}'
        : step == _calcLength()
            ? 'No winner...'
            : 'Turn: ${_calcPlayer(step + 1)}';
    return Container(
      color: _light,
      child: Row(
        children: [
          StatusParagraph(
            child: StatusParagraphText(text),
          ),
          StatusMenu(
            children: [
              StatusMenuButton(
                child: StatusMenuButtonText('Clear'),
                onPressed: this.clear,
              ),
              StatusMenuButton(
                child: StatusMenuButtonText('Undo'),
                onPressed: this.undo,
              ),
              StatusMenuButton(
                child: StatusMenuButtonText('Redo'),
                onPressed: this.redo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BoardTrackButtonText extends StatelessWidget {
  final String data;

  BoardTrackButtonText(this.data);

  Widget build(BuildContext context) {
    return Text(
      this.data,
      style: TextStyle(
        color: _dark,
        height: 1.25,
        fontSize: 16,
      ),
    );
  }
}

class BoardTrackButton extends StatelessWidget {
  final Widget child;
  final void Function() onPressed;

  BoardTrackButton({
    @required this.child,
    @required this.onPressed,
  });

  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(5),
        child: RawMaterialButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          fillColor: _light,
          child: this.child,
          onPressed: this.onPressed,
        ),
      ),
    );
  }
}

class BoardTrack extends StatelessWidget {
  final List<Widget> children;

  BoardTrack({
    this.children = const [],
  });

  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: this.children,
        ),
      ),
    );
  }
}

class Board extends StatelessWidget {
  final _BoardData data;
  final void Function(int index) fill;

  Board(
    this.data, {
    @required this.fill,
  });

  Widget build(BuildContext context) {
    final int size = _calcSize();
    final board = this.data;
    final squares = board.squares;
    final List<Widget> cells = [
      for (MapEntry<int, String> entry in squares.asMap().entries)
        BoardTrackButton(
          child: BoardTrackButtonText(entry.value),
          onPressed: () => this.fill(entry.key),
        ),
    ];
    final List<Widget> rows = [
      for (int index = 0; index < size; ++index)
        BoardTrack(
          children: cells.sublist(index * size, (index + 1) * size),
        ),
    ];
    return Expanded(
      child: Container(
        color: _dark,
        padding: EdgeInsets.symmetric(
          vertical: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        ),
      ),
    );
  }
}

class Game extends StatefulWidget {
  _GameState createState() {
    return _GameState();
  }
}

class _GameState extends State<Game> {
  final _GameData _data;

  _GameState._(this._data);

  factory _GameState() {
    final int step = 0;
    final int length = _calcLength();
    final String noPlayer = _calcNoPlayer();
    final List<String> squares = List<String>.filled(length, noPlayer);
    final bool winner = false;
    final List<_HistoryStep> history = [_HistoryStep(squares, winner)];
    final _GameData data = _GameData(step, history);
    return _GameState._(data);
  }

  Widget build(BuildContext context) {
    final game = this._data;
    final int step = game.step;
    final List<_HistoryStep> history = game.history;
    final _HistoryStep historyStep = history[step];
    final squares = historyStep.squares;
    final winner = historyStep.winner;
    final _StatusData status = _StatusData(step, winner);
    final _BoardData board = _BoardData(squares);
    return Column(
      children: [
        Status(
          status,
          clear: this._clear,
          undo: this._undo,
          redo: this._redo,
        ),
        Board(
          board,
          fill: this._fill,
        ),
      ],
    );
  }

  void _fill(int index) {
    final game = this._data;
    final int step = game.step;
    final List<_HistoryStep> history = game.history;
    final _HistoryStep historyStep = history[step];
    final squares = historyStep.squares;
    final winner = historyStep.winner;
    final String noPlayer = _calcNoPlayer();
    if (winner || squares[index] != noPlayer) {
      return;
    }
    this.setState(() {
      final int nextStep = step + 1;
      final List<String> nextSquares = List.from(squares);
      final String nextPlayer = _calcPlayer(nextStep);
      nextSquares[index] = nextPlayer;
      final bool nextWinner = _isWinner(nextSquares, nextPlayer);
      game.step = nextStep;
      history.removeRange(nextStep, history.length);
      history.add(_HistoryStep(nextSquares, nextWinner));
    });
  }

  void _clear() {
    final game = this._data;
    final List<_HistoryStep> history = game.history;
    this.setState(() {
      final int nextStep = 0;
      game.step = nextStep;
      history.removeRange(1, history.length);
    });
  }

  void _undo() {
    final game = this._data;
    final int step = game.step;
    if (step == 0) {
      return;
    }
    this.setState(() {
      final int nextStep = step - 1;
      game.step = nextStep;
    });
  }

  void _redo() {
    final game = this._data;
    final int step = game.step;
    final List<_HistoryStep> history = game.history;
    if (step + 1 == history.length) {
      return;
    }
    this.setState(() {
      final int nextStep = step + 1;
      game.step = nextStep;
    });
  }
}

void main() {
  runApp(
    MaterialApp(
      title: _title,
      home: new Scaffold(
        body: new SafeArea(
          child: Game(),
        ),
      ),
    ),
  );
}
