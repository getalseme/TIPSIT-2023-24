import 'dart:io';

// USE also netcat 127.0.0.1 3000SHOW

// global variable must be initialized later (null safety)
//late Client client;

void main() {
  ServerGame s = ServerGame(3000);
  s.start();
}

void messageHandler(data, client) {
  String message = String.fromCharCodes(data).trim();
  writeMessage(client, message);
}

void errorHandler(error, client) {
  print(' Error: $error');
  client.finishedHandler();
}

void finishedHandler(client) {
  client.finishedHandler();
}

void writeMessage(Client client, String message) {
  String str = message.toUpperCase();
  print('[' + client.get_n() + ']: ' + str);
  client.write(str + '\t');
}

class ServerGame {

  late int _port;

  static List<Client> players = [];

  ServerGame(port){
    _port = port;
  }
  
  void start(){
    ServerSocket.bind('192.168.204.106', _port).then((ServerSocket server) {
      print("server start");
      server.listen((socket) {
        handleConnection(socket);
      });
    });
  }

  void handleConnection(Socket socket) {
    Client client = Client(socket);
    players.add(client);
    print('client ' +
      client.get_n() +
      ' connected from ' +
      '${socket.remoteAddress.address}:${socket.remotePort}'
    );
    firstMessage(socket);
  }

  void firstMessage(Socket socket){
    socket.write('HI'); 
  }

  static bool matchMaking(Client client){
    print('match call from client ' + client.get_n());
    int first = -1;
    int second = -1;
    for(int i = 0; i < players.length; i++){
      if(players[i].isPlaying == false && players[i].ready){
        first = i;
        break;
      }
    }
    for(int i = first + 1; i < players.length; i++){
      if(players[i].isPlaying == false && players[i].ready){
        second = i;
        break;
      }
    }
    if(first == -1 || second == -1){
      print('NO ONE READY');
      client.write('W_OP\t');
      return false;
    }else{
      players[first].opponent = players[second];
      players[second].opponent = players[first];
      players[first].isTurn = true;
      players[first].isPlaying = true;
      players[second].isPlaying = true;
      players[first].write('F_OP\t');
      players[second].write('F_OP\t');
      players[first].write('TURN\t');
      players[second].write('W_TURN\t');
      return true;
    }
  }
}

class Landpiece {

  late bool _taken;
  late bool _hitted;

  Landpiece(){
    _hitted = false;
    _taken = false;
  }

  @override
  String toString(){
    if(_hitted == false){
      return ' ';
    }else if(_hitted && _taken){
      return 'X';
    }else{
      return 'O';
    }
  }

  String personalString(){
    if(_hitted){
      if (_taken){
        return 'X';
      }else{
        return 'O';
      }
    }else{
      if(_taken){
        return 'N';
      }else{
        return ' ';
      }
    }
  }

  void setHit(){
    _hitted = true;
  }

  void setTake(){
    _taken = true;
  }

  bool getTake(){
    return _taken;
  }

  bool getHit(){
    return _hitted;
  }

}




// the client

class Client {

  static int N = 0;
  late Socket _socket;
  String get _address => _socket.remoteAddress.address;
  int get _port => _socket.remotePort;
  late int _n;

  int hit = 0;

  late Client opponent;

  bool done = false;
  bool isPlaying = false;
  bool ready = false;
  bool isTurn = false;
  var _clientLand = List<List>.generate(10, (i) => List<Landpiece>.generate(10, (index) => Landpiece(), growable: false), growable: false);
  List<int> ships = [2, 3, 3, 4, 5];

  static final int maxHit = 17;

  Client(Socket s) {
    _n = ++N;
    _socket = s;
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  void doneGame(){
    _socket.write("FINISH");
    ServerGame.players.remove(this);
    done = true;
  }

  void printClientLand(){
    String mes = 'MAP\n';
    for(int i = 0; i < 10; i++){
      for(int j = 0; j < 9; j++){
        mes += (_clientLand[i][j].personalString() + '-');
      }
      mes += (_clientLand[i][9].personalString() + '\n');
    }
    _socket.write(mes + '\t');
  }

  void printOpponentLand(){
    String mes = 'MAP OP\n';
    for(int i = 0; i < 10; i++){
      for(int j = 0; j < 9; j++){
        mes += (opponent.getLand()[i][j].toString() + '-');
      }
      mes += (opponent.getLand()[i][9].toString() + '\n');
    }
    _socket.write(mes + '\t');
  }

  String get_n(){
    return _n.toString();
  }

  List<List<dynamic>> getLand(){
    return _clientLand;
  }

  void messageHandler(data){
    if(done){
      _socket.write('FINISHED');
      return;
    }
    String message = String.fromCharCodes(data).trim();
    if(message == 'SHOW ME'){
      printClientLand();
      return;
    }
    if(message == 'SHOW OP' && isPlaying){
      printOpponentLand();
      return;
    }
    if(isPlaying && isTurn){
      List<String> messages = message.split(' ');
      if(checkMessageAttack(messages)){
        if(opponent.getLand()[int.parse(messages[1])][int.parse(messages[0])].getTake()){
          _socket.write('HIT\t');
          opponent.write('HITTED\t');
          opponent.hit += 1;
          if(opponent.hit == Client.maxHit){
            opponent.write('LOSE\t');
            _socket.write('WIN\t');
            opponent.doneGame();
            doneGame();
            return;
          }
        }
        else{
          _socket.write('MISS\t');
          opponent.write('MISSED\t');
        }
        opponent.getLand()[int.parse(messages[1])][int.parse(messages[0])].setHit();
        isTurn = false;
        _socket.write('W_TURN\t');
        opponent.isTurn = true;
        opponent.write('TURN\t');
      }
      return;
    }
    if(ready == true && isPlaying == false){
      ServerGame.matchMaking(this);
      return;
    }
    //SEZIONE DELLA DISPOSIZIONE DELLE NAVI
    if(ready == false){
      List<String> messages = message.split(' ');
      if(checkMessageShip(messages)){
        ships.remove(int.parse(messages[2]));
        if(messages[3].toUpperCase() == 'ORI'){
          for(int i = int.parse(messages[0]); i < (int.parse(messages[0]) + int.parse(messages[2])); i++){
            _clientLand[int.parse(messages[1])][i].setTake();
          }
        }else{
          for(int i = int.parse(messages[1]); i < (int.parse(messages[1]) + int.parse(messages[2])); i++){
            _clientLand[i][int.parse(messages[0])].setTake();
          }
        }
        _socket.write('OK\t');
        if(ships.length == 0){
          _socket.write('READY\t');
          ready = true;
          ServerGame.matchMaking(this);
        }
        return;
      }
      _socket.write('NO\t');
      return;
    }
  }


  bool checkMessageAttack(List<String> message){
    print('check attack');
    if(int.parse(message[0]) < 0 ||  int.parse(message[0]) > 9 || int.parse(message[1]) < 0 || int.parse(message[1]) > 9){
      print('attack no correct');
      return false;
    }else{
      if(opponent.getLand()[int.parse(message[1])][int.parse(message[0])].getHit() == false){
        return true;
      }
      print('already attacked');
      return false;
    }
  }


  //METODO CHE FA IL CHECK DELLE INFORMAZIONI INVIATE DAL CLIENT,
  //PER QUANTO RIGUARDA LA FASE DI DISPOSIZIONE DELLE NAVI
  bool checkMessageShip(List<String> message){
    if(message.length < 4){
      return false;
    }else{
      if(int.parse(message[0]) < 0 ||  int.parse(message[0]) > 9 || int.parse(message[1]) < 0 || int.parse(message[1]) > 9){
        return false;
      }
      else{
        if(ships.contains(int.parse(message[2]))){
          if(message[3].toUpperCase() == 'ORI'){
            int total = int.parse(message[2]) + int.parse(message[0]);
            if(total > 10){
              return false;
            }else{
              for(int i = int.parse(message[0]); i < total; i++){
                if(_clientLand[int.parse(message[1])][i].getTake()){
                  return false;
                }
              }
              return true;
            }
          }else if(message[3].toUpperCase() == 'VER'){
            int total = int.parse(message[2]) + int.parse(message[1]);
            if(total > 10){
              return false;
            }else{
              for(int i = int.parse(message[1]); i < total; i++){
                if(_clientLand[i][int.parse(message[0])].getTake()){
                  return false;
                }
              }
              return true;
            }
          }else{
            return false;
          }
        }else{
          return false;
        }
      }
    }
  }

  void errorHandler(error) {
    print('${_address}:${_port} Error: $error');
    _socket.close();
  }

  void finishedHandler() {
    print('${_address}:${_port} Disconnected');
    ServerGame.players.remove(this);
    _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }
}
