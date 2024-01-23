import 'dart:async';
import 'dart:io';
import 'land.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/*
* author @ANDREA.VERDICCHIO
 */

late ClientGame cg;

void main() {
  cg = ClientGame();
  runApp(const MyApp());
}

class ClientGame{

  late Socket socket;

  final Land _landOp = Land();
  final Land _land = Land();

  bool _ready = false;
  bool _playing = false;
  bool _isTurn = false;
  bool _finish = false;
  final bool _win = true;

  String startMessage = '';

  List<String> serverResponce = [];

  ClientGame(){
    startConnection();
  }

    List<List<String>> getLand(){
      return _land.getMatrix();
    }

    List<List<String>> getLandOp(){
      return _landOp.getMatrix();
    }

    void writeToServer(String message){
      socket.write(message);
    }

    void startConnection(){
      Socket.connect('192.168.62.106', 3000).then((Socket sock) {
      this.socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
      }, onError: (e) {
        if (kDebugMode) {
          print("Unable to connect: $e");
        }
        exit(1);
      });
    }

  void errorHandler(error, StackTrace trace) {
    if (kDebugMode) {
      print(error);
    }
  }

  void doneHandler() {
    socket.destroy();
    exit(0);  
  }
 
  void dataHandler(data) {
    String msgs = String.fromCharCodes(data).trim();
    List<String> msg = msgs.split('\t');
    //print(msg);
    int n = msg.length;
    for (int i = 0; i < n; i++){
      if(msg[i].contains('MAP OP')){
        _landOp.messageToGrid(msg[i]);
        continue;
      }
      if(msg[i].contains('MAP')){
        _land.messageToGrid(msg[i]);
        continue;
      }
      if(_ready){
        if(_playing){
          if(msg[i] == 'WIN'){
            print('CONGRATULATIONS, YOU WON THE GAME');
            continue;
          }
          if(msg[i] == 'LOSE'){
            print('WHAT A SHAME, YOU LOST THE GAME');
            continue;
          }
          if(msg[i] == 'FINISHED'){
            print('THE GAME IS FINISHED');
            _finish = true;
          }
          if(msg[i] == 'TURN'){
            print("IT'S YOUR TURN");
            _isTurn = true;
            continue;
          }
          if(msg[i] == 'W_TURN'){
            print("WAIT YOUR TURN");
            _isTurn = false;
            continue;
          }
          if(msg[i] == 'HIT'){
            print("YOU HITTED ONE OF YOUR ENEMY'S SHIPS");
            socket.write('SHOW OP');
            continue;
          }
          if(msg[i] == 'HITTED'){
            print('ONE OF YOUR SHIPS HAS BEEN HITTED');
            socket.write('SHOW ME');
            continue;
          }
          if(msg[i] == 'MISS'){
            print("YOU MISSED YOUR ENEMY'S SHIPS");
            socket.write('SHOW OP');
            continue;
          }
          if(msg[i] == 'MISSED'){
            print('YOUR SHIPS HAS BEEN MISSED');
            socket.write('SHOW ME');
            continue;
          }
        }
        if(msg[i] == 'W_OP'){
          print('WAIT FOR AN OPPONENT');
          continue;
        }
        if(msg[i] == 'F_OP'){
          print('FOUND AN OPPONENT');
          _playing = true;
          continue;
        }
      }else{
        if(msg[i] == 'READY'){
          print('SHIPS SUCCESFULLY PLACED');
          _ready = true;
          continue;
        }
        if(msg[i] == 'HI'){
          print(  'WELLCOME\n' + 
                  'YOU HAVE TO PLACE YOUR SHIPS\n' + 
                  'THEIR DIMENTIONS ARE: 5 - 4 - 3 - 3 - 2\n' + 
                  'YOU HAVE TO WRITE THE COORDINATES AND THE ORIETETION IN THIS WAY:\n' +
                  '"X Y DIM ORI/VER" FOR EXEMPLLE -> "1 8 5 ORI"');
          continue;
        }
        if(msg[i] == 'OK'){
          print('COMMAND ACCEPTED');
          ships.removeAt(selectedShip);
          socket.write('SHOW ME');
          continue;
        }
        if(msg[i] == 'NO'){
          print('COMMAND NOT ACCEPTED');
          //serverResponce.add(msg[i]);
          continue;
        }
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battleship Game',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const BattleshipGame(),
    );
  }
}

class BattleshipGame extends StatefulWidget {
  const BattleshipGame({super.key});

  @override
  _BattleshipGameState createState() => _BattleshipGameState();
}

final List<int> ships = [2, 3, 3, 4, 5];
int selectedShip = 0;

class _BattleshipGameState extends State<BattleshipGame> {
  int currentGrid = 1; // Variable to track the current grid (1 or 2)

  late Timer _timer;
 
  List<List<String>> grid1 = cg.getLand();
  List<List<String>> grid2 = cg.getLandOp();

  List<List<String>> getCurrentGrid() {
    return currentGrid == 1 ? grid1 : grid2;
  }

  String selectedOrientation = 'horizontal';

  void switchGrid() {
    setState(() {
      currentGrid = (currentGrid == 1) ? 2 : 1;
    });
  }

  void updateAllGrids(Timer timer) {
    setState(() {
      // Update both grid1 and grid2 with new data
      grid1 = cg.getLand();
      grid2 = cg.getLandOp();
    });
  }

  void cellSelected(int row, int col) {
    // Check if ship placement is valid here
    if (kDebugMode) {
      print('Cell selected: Row $row, Col $col');
    }
    if(cg._playing && cg._isTurn){
      cg.writeToServer('$col $row');
    }else{
    // For demonstration purposes, let's update the selected cell with 'X'
    int ship = ships[selectedShip];

    if(selectedOrientation == 'vertical'){
      cg.writeToServer('$col $row $ship VER');  
    }else{
      cg.writeToServer('$col $row $ship ORI');    
    }
    }
  }

  void selectOrientation(String orientation) {
    setState(() {
      selectedOrientation = orientation;
    });
  }

  @override
  void initState() {
    super.initState();

    // Start the periodic timer when the widget is initialized
    _timer = Timer.periodic(const Duration(milliseconds: 100), updateAllGrids);
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is removed from the widget tree
    _timer.cancel();
    super.dispose();
  }

  void startPlayerTurnCheck() {
    // Controlla periodicamente lo stato del turno del giocatore
    Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        // Utilizza la variabile _isTurn dalla classe ClientGame
        // Per esempio, se _isTurn è true, nascondi il popup
        if (cg._isTurn) {
          // Nascondi il popup se è il turno del giocatore
          // Aggiorna l'interfaccia in base a ciò che è necessario
          // ... codice per nascondere il popup o consentire l'interazione
        } else {
          // Mostra il popup se non è il turno del giocatore
          // ... codice per mostrare il popup fisso
        }
      });
    });
  }

  String getCurrentGridName(){
    if(getCurrentGrid() == grid1){
      return "LA MIA FLOTTA";
    }
    else{
      return "FLOTTA NEMICA";
    }
  }

  Widget buildInitialSetup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Select Ship Size:',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: ships.map((shipSize) {
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedShip = ships.indexOf(shipSize);
                });
              },
              style: selectedShip == ships.indexOf(shipSize)
                  ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              child: Text('$shipSize'),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Select Orientation:',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                selectOrientation('horizontal');
              },
              style: selectedOrientation == 'horizontal'
                  ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              child: const Text('Horizontal'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                selectOrientation('vertical');
              },
              style: selectedOrientation == 'vertical'
                  ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              child: const Text('Vertical'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Display grid for ship placement
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: GridView.builder(
            itemCount: 100,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ 10;
              final col = index % 10;
              final currentMatrix = getCurrentGrid();
              return GestureDetector(
                onTap: () {
                  cellSelected(row, col);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Text(
                      currentMatrix[row][col],
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if(ships.isNotEmpty){
      return Scaffold(
        appBar: AppBar(
          title: const Text('Battleship Game'),
        ),
        body: Center(
          child: buildInitialSetup(),
        ),
      );  
    }else{
      return Scaffold(
        appBar: AppBar(
          title: const Text('Battleship Game'),
        ),
        body: Stack(
          children: [
            // Widget principale (griglia di gioco)
            buildGameGrid(),
            // Popup fisso quando isTurn è false
            if (!cg._isTurn)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'ATTENDERE, turno dell\'avversario',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            if(!cg._playing)
              Container(
                color: Colors.black, // Sfondo scuro per il popup
                child: const Center(
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'ATTENDERE, ricerca di un avversario in corso',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            if(cg._finish && cg._win)
                Container(
                  color: Colors.black, // Sfondo scuro per il popup
                  child: const Center(
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'CONGRATULAZIONI HAI VINTO!',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              if(cg._finish && !cg._win)
                Container(
                  color: Colors.black, // Sfondo scuro per il popup
                  child: const Center(
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "HAI PERSO! :(",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      );
    }
  }

  Widget buildGameGrid(){
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        getCurrentGridName(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
      ),
      const SizedBox(height: 10), // Spazio tra il nome e la griglia
      Expanded(
        child: GridView.builder(
          itemCount: 100, // 10x10 grid
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ 10;
            final col = index % 10;
            final currentMatrix = getCurrentGrid();
            return GestureDetector(
              onTap: () {
                cellSelected(row, col);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(
                  child: Text(
                    currentMatrix[row][col],
                    style: const TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              switchGrid();
            },
            child: const Text('Switch Grid'),
          ),
        ],
      ),
    ],
  );
}
}