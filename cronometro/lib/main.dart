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

  Stream<int> get timerStream => _controller.stream;

  TimerBloc() {
    _timer = Timer.periodic(Duration(milliseconds: 10), _tick);
  }

  void _tick(Timer timer) {
    _counter++;
    _controller.sink.add(_counter);
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 10), _tick);
  }

  void stopTimer() {
    _timer.cancel();
  }

  void resetTimer() {
    _counter = 0;
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

  String formatTime(int centiseconds) {
    int hours = centiseconds ~/ 360000;
    int minutes = (centiseconds ~/ 6000) % 60;
    int seconds = (centiseconds ~/ 100) % 60;
    int cs = centiseconds % 100;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';
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
                    formatTime(snapshot.data!),
                    style: TextStyle(fontSize: 48),
                  );
                } else {
                  return Text(
                    '0:00:00.00',
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
