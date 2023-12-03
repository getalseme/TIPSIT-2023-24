import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battleship Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BattleshipGame(),
    );
  }
}

class BattleshipGame extends StatefulWidget {
  @override
  _BattleshipGameState createState() => _BattleshipGameState();
}

class _BattleshipGameState extends State<BattleshipGame> {
  int currentGrid = 1; // Variable to track the current grid (1 or 2)
  List<List<String>> grid1 = List.generate(
    10,
    (_) => List.filled(10, '-'),
  );

  List<List<String>> grid2 = List.generate(
    10,
    (_) => List.filled(10, '-'),
  );

  List<List<String>> getCurrentGrid() {
    return currentGrid == 1 ? grid1 : grid2;
  }

  // Store the ships' sizes
  final List<int> ships = [2, 3, 3, 4, 5];
  int selectedShip = 0; // Index of the selected ship size
  String selectedOrientation = 'horizontal'; // Initial orientation

  void switchGrid() {
    setState(() {
      currentGrid = (currentGrid == 1) ? 2 : 1;
    });
  }

  void cellSelected(int row, int col) {
    // Check if ship placement is valid here
    print('Cell selected: Row $row, Col $col');
    // For demonstration purposes, let's update the selected cell with 'X'
    setState(() {
      getCurrentGrid()[row][col] = 'X';
    });

    // Disable the placed ship's button
    setState(() {
      ships.removeAt(selectedShip);
      selectedShip = 0;
    });
  }

  void selectOrientation(String orientation) {
    setState(() {
      selectedOrientation = orientation;
    });
  }

  Widget buildInitialSetup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Select Ship Size:',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: ships.map((shipSize) {
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedShip = ships.indexOf(shipSize);
                });
              },
              child: Text('$shipSize'),
              style: selectedShip == ships.indexOf(shipSize)
                  ? ElevatedButton.styleFrom(primary: Colors.green)
                  : null,
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        Text(
          'Select Orientation:',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                selectOrientation('horizontal');
              },
              child: Text('Horizontal'),
              style: selectedOrientation == 'horizontal'
                  ? ElevatedButton.styleFrom(primary: Colors.green)
                  : null,
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                selectOrientation('vertical');
              },
              child: Text('Vertical'),
              style: selectedOrientation == 'vertical'
                  ? ElevatedButton.styleFrom(primary: Colors.green)
                  : null,
            ),
          ],
        ),
        SizedBox(height: 20),
        // Display grid for ship placement
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: GridView.builder(
            itemCount: 100,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ 10;
              final col = index % 10;
              final currentMatrix = getCurrentGrid();
              return GestureDetector(
                onTap: () {
                  if (selectedShip > 0) {
                    cellSelected(row, col);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Text(
                      currentMatrix[row][col],
                      style: TextStyle(fontSize: 20.0),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Battleship Game'),
      ),
      body: Center(
        child: currentGrid == 1 ? buildInitialSetup() : buildGameGrid(),
      ),
    );
  }

  Widget buildGameGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GridView.builder(
            itemCount: 100, // 10x10 grid
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ 10;
              final col = index % 10;
              final currentMatrix = getCurrentGrid();
              return GestureDetector(
                onTap: () {
                  if (selectedShip > 0) {
                    cellSelected(row, col);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Text(
                      currentMatrix[row][col],
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                switchGrid();
              },
              child: Text('Switch Grid'),
            ),
          ],
        ),
      ],
    );
  }
}
