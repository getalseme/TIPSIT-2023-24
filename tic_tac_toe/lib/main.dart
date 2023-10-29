import 'package:flutter/material.dart';

void main() => runApp(TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late List<String> _board;
  late String _currentPlayer;
  String? _winner;
  int xScore = 0;
  int oScore = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = null;
    });
  }

  void _handleTap(int index) {
    if (_board[index].isEmpty && _winner == null) {
      setState(() {
        _board[index] = _currentPlayer;
        if (_checkForWinner(index)) {
          _winner = _currentPlayer;
          if (_winner == 'X') {
            xScore++;
          } else if (_winner == 'O') {
            oScore++;
          }
          _showEndGameDialog();
        } else if (_board.every((element) => element.isNotEmpty)) {
          // It's a draw
          _showEndGameDialog(draw: true);
        } else {
          _currentPlayer = (_currentPlayer == 'X') ? 'O' : 'X';
        }
      });
    }
  }

  bool _checkForWinner(int index) {
    final winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final combo in winningCombinations) {
      if (combo.contains(index) &&
          _board[combo[0]] == _currentPlayer &&
          _board[combo[1]] == _currentPlayer &&
          _board[combo[2]] == _currentPlayer) {
        return true;
      }
    }

    return false;
  }

  void _showEndGameDialog({bool draw = false}) {
    String message;
    if (draw) {
      message = "It's a draw!";
    } else {
      message = 'Player $_winner wins!';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startNewGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe'),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Text('X Score: $xScore'),
              SizedBox(width: 10),
              Text('O Score: $oScore'),
            ],
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            (_winner == null)
                ? 'Current Player: $_currentPlayer'
                : 'Winner: $_winner',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      _board[index],
                      style: TextStyle(
                        fontSize: 48,
                        color: _board[index] == 'X' ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: 9,
            shrinkWrap: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startNewGame,
            child: Text('New Game'),
          ),
        ],
      ),
    );
  }
}
