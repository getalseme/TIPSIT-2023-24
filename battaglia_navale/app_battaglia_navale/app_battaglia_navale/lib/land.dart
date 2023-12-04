class Land{

  late List<List<String>> _matrix;

  Land(){
    initialize_matrix();
  }

  void initialize_matrix(){
      _matrix = List<List<String>>.generate(10, (i) => List<String>.generate(10, (index) => ' ', growable: false), growable: false);
  }

  List<List<String>> getMatrix(){
    return _matrix;
  }

  void setPoint(int x, int y, String value){
    _matrix[y][x] = value;
  }

  void messageToGrid(String msg){
    List<String> msgs = msg.split('\n');
    for (int i = 0; i < 10; i++){
      for(int j = 0; j < 10; j++){
        _matrix[i][j] = msgs[(i + 1)].split('-')[j];
      }
    }
  }

}

