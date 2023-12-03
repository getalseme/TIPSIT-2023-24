void main(){
  print('STARTED PROGRAM');
  Land l = Land();
  String msg =  "MAP\n -X- - - - - - - - \nO- - - - - - - - - \n - -N- - - - - - - \n - - - - - - - - - \n - - - - - - - - - \n - - - - - - - - - \n - - - - - - - - - \n - - - - - - - - - \n - - - - - - - - - \n - - - - - - - - - \n";
  l.messageToGrid(msg);
  print(l.matrix[0][1]);
  print(l.matrix[1][0]);
  print(l.matrix[2][2]);
}

class Land{


  late List<List<String>> matrix;

  Land(){
    initialize_matrix();
  }

  void initialize_matrix(){
      matrix = List<List<String>>.generate(10, (i) => List<String>.generate(10, (index) => ' ', growable: false), growable: false);
  }

  void setCell(int x, int y, String value){
    matrix[y][x] = value;
  }

  void messageToGrid(String msg){
    List<String> msgs = msg.split('\n');
    for (int i = 0; i < 10; i++){
      for(int j = 0; j < 10; j++){
        matrix[i][j] = msgs[(i + 1)].split('-')[j];
      }
    }
  }

}

