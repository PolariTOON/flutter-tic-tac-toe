import 'package:flutter/material.dart'
    show
        BorderRadius,
        BuildContext,
        Color,
        Column,
        Container,
        CrossAxisAlignment,
        EdgeInsets,
        Expanded,
        FlatButton,
        MaterialApp,
        RoundedRectangleBorder,
        Row,
        SafeArea,
        Scaffold,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        Widget,
        runApp;

final _title = 'Tic Tac Toe';
final _dark = Color(0xff333333);
final _light = Color(0xffffffff);

final int _size = 3;
final int _length = _size * _size;
final String _noPlayer = '';
final List<String> _players = ['0', 'X'];

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

bool _isWinner(List<String> board, String player) {
  final int size = _calcSize();
  rows:
  for (int i = 0; i < size; ++i) {
    for (int j = 0; j < size; ++j) {
      if (board[i * size + j] != player) {
        continue rows;
      }
    }
    return true;
  }
  columns:
  for (int i = 0; i < size; ++i) {
    for (int j = 0; j < size; ++j) {
      if (board[j * size + i] != player) {
        continue columns;
      }
    }
    return true;
  }
  diagonals:
  for (int i = 0; i < 2; ++i) {
    for (int j = 0; j < size; ++j) {
      if (board[(i + j) * (size + 1 - i * 2)] != player) {
        continue diagonals;
      }
    }
    return true;
  }
  return false;
}

class Status extends StatelessWidget {
  final int _step;
  final bool _winner;
  final void Function() _clear;
  final void Function() _undo;
  final void Function() _redo;

  Status(this._step, this._winner, this._clear, this._undo, this._redo);

  Widget build(
    BuildContext context,
  ) {
    final int step = this._step;
    final bool winner = this._winner;
    final String text = winner
        ? 'Winner: ${_calcPlayer(step)}'
        : step == _calcLength()
            ? 'No winner...'
            : 'Turn: ${_calcPlayer(step + 1)}';
    return Container(
      color: _light,
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: Text(text),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  child: FlatButton(
                    textColor: _light,
                    color: _dark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text('Clear'),
                    onPressed: () {
                      this._clear();
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: FlatButton(
                    textColor: _light,
                    color: _dark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text('Undo'),
                    onPressed: () {
                      this._undo();
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: FlatButton(
                    textColor: _light,
                    color: _dark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text('Redo'),
                    onPressed: () {
                      this._redo();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Board extends StatelessWidget {
  final List<String> _board;
  final void Function(int index) _fill;

  Board(this._board, this._fill);

  Widget build(
    BuildContext context,
  ) {
    final int size = _calcSize();
    final List<Widget> cells = [
      for (MapEntry<int, String> entry in this._board.asMap().entries)
        Expanded(
          child: Container(
            margin: EdgeInsets.all(5),
            child: FlatButton(
              textColor: _dark,
              color: _light,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(10),
              child: Text(entry.value),
              onPressed: () {
                this._fill(entry.key);
              },
            ),
          ),
        ),
    ];
    final List<Widget> rows = [
      for (int index = 0; index < size; ++index)
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cells.sublist(
                index * size,
                (index + 1) * size,
              ),
            ),
          ),
        ),
    ];
    return Expanded(
      child: Container(
        color: _dark,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
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

class _HistoryStep {
  final List<String> board;
  final bool winner;
  _HistoryStep(this.board, this.winner);
}

class _GameState extends State<Game> {
  int _step;
  List<_HistoryStep> _history;

  _GameState() {
    final int step = 0;
    final int length = _calcLength();
    final String noPlayer = _calcNoPlayer();
    final List<String> board = List<String>.filled(length, noPlayer);
    final bool winner = false;
    final List<_HistoryStep> history = [_HistoryStep(board, winner)];
    this._step = step;
    this._history = history;
  }

  Widget build(
    BuildContext context,
  ) {
    final int step = this._step;
    final List<_HistoryStep> history = this._history;
    final _HistoryStep historyStep = history[step];
    final board = historyStep.board;
    final winner = historyStep.winner;
    return Column(
      children: [
        Status(step, winner, this._clear, this._undo, this._redo),
        Board(board, this._fill),
      ],
    );
  }

  void _fill(int index) {
    final int step = this._step;
    final List<_HistoryStep> history = this._history;
    final _HistoryStep historyStep = history[step];
    final board = historyStep.board;
    final winner = historyStep.winner;
    final String noPlayer = _calcNoPlayer();
    if (winner || board[index] != noPlayer) {
      return;
    }
    this.setState(
      () {
        final int nextStep = step + 1;
        final List<String> nextBoard = List.from(board);
        final String nextPlayer = _calcPlayer(nextStep);
        nextBoard[index] = nextPlayer;
        final bool nextWinner = _isWinner(nextBoard, nextPlayer);
        this._step = nextStep;
        history.removeRange(nextStep, history.length);
        history.add(_HistoryStep(nextBoard, nextWinner));
      },
    );
  }

  void _clear() {
    final List<_HistoryStep> history = this._history;
    this.setState(
      () {
        final int nextStep = 0;
        this._step = nextStep;
        history.removeRange(1, history.length);
      },
    );
  }

  void _undo() {
    final int step = this._step;
    if (step == 0) {
      return;
    }
    this.setState(
      () {
        final int nextStep = step - 1;
        this._step = nextStep;
      },
    );
  }

  void _redo() {
    final int step = this._step;
    final List<_HistoryStep> history = this._history;
    if (step + 1 == history.length) {
      return;
    }
    this.setState(
      () {
        final int nextStep = step + 1;
        this._step = nextStep;
      },
    );
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
