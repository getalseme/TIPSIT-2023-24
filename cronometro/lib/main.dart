import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class TimerBloc {
  final _controller = StreamController<int>();
  late Timer _timer;
  int _counter = 0;
  bool _isRunning = false;

  Stream<int> get timerStream => _controller.stream;

  void startTimer() {
    if (!_isRunning) {
      _timer = Timer.periodic(Duration(milliseconds: 100), _tick);
      _isRunning = true;
    }
  }

  void stopTimer() {
    if (_isRunning) {
      _timer.cancel();
      _isRunning = false;
    }
  }

  void resetTimer() {
    _counter = 0;
    _controller.sink.add(_counter);
  }

  void _tick(Timer timer) {
    _counter++;
    _controller.sink.add(_counter);
  }

  void dispose() {
    _timer.cancel();
    _controller.close();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _bloc = TimerBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  String formatTime(int deciseconds) {
    int seconds = deciseconds ~/ 10;
    int minutes = (seconds ~/ 60) % 60;
    int hours = (seconds ~/ 3600);
    seconds = seconds % 60;
    int ds = deciseconds % 10;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ds.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cronometro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<int>(
              stream: _bloc.timerStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    formatTime(snapshot.data ?? 0),
                    style: TextStyle(fontSize: 48),
                  );
                } else {
                  return Text(
                    '0:00:0',
                    style: TextStyle(fontSize: 48),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _bloc.startTimer();
                  },
                  child: Text('Avvia'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _bloc.stopTimer();
                  },
                  child: Text('Ferma'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _bloc.resetTimer();
                  },
                  child: Text('Resetta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

