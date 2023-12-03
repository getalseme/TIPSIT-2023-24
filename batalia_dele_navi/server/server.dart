import 'dart:io';

// USE also netcat 127.0.0.1 3000

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
  client.write(str + '\n');
}

class ServerGame {

  late int _port;

  static List<Client> _players = [];


  ServerGame(port){
    _port = port;
  }
  
  void start(){
    ServerSocket.bind('127.0.0.1', _port).then((ServerSocket server) {
      print("server start");
      server.listen((socket) {
        handleConnection(socket);
      });
    });
  }

  void handleConnection(Socket socket) {
    Client client = Client(socket);
    _players.add(client);
    print('client ' +
      client.get_n() +
      ' connected from ' +
      '${socket.remoteAddress.address}:${socket.remotePort}'
    );
    firstMessage(socket);
  }

  void firstMessage(Socket socket){
    socket.write( 'WELLCOME\n' + 
                  'YOU HAVE TO PLACE YOUR SHIPS\n' + 
                  'THEIR DIMENTIONS ARE: 5 - 4 - 3 - 3 - 2\n' + 
                  'YOU HAVE TO WRITE THE COORDINATES AND THE ORIETETION IN THIS WAY:\n' +
                  '"X Y DIM ORI/VER" FOR EXEMPLLE -> "1 8 5 ORI"\n');
  }

  static bool matchMaking(Socket socket){
    int first = -1;
    int second = -1;
    for(int i = 0; i < _players.length; i++){
      if(_players[i].isPlaying == false && _players[i].ready){
        first = i;
        break;
      }
    }
    for(int i = first; i < _players.length; i++){
      if(_players[i].isPlaying == false && _players[i].ready){
        second = i;
        break;
      }
    }
    if(first == -1 || second == -1){
      return false;
    }else{
      _players[first].opponent = _players[second];
      _players[second].opponent = _players[first];
      _players[first].isTurn = true;
      _players[first].isPlaying = true;
      _players[second].isPlaying = true;
      _players[first].write('FOUND THE OPPONENT\n');
      _players[second].write('FOUND THE OPPONENT\n');
      _players[first].write('YOUR TURN\n');
      _players[second].write('WAIT YOUR TURN\n');
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

  bool isPlaying = false;
  bool ready = false;
  bool isTurn = false;
  var _clientLand = List<List>.generate(10, (i) => List<Landpiece>.generate(10, (index) => Landpiece(), growable: false), growable: false);
  List<int> ships = [2];

  Client(Socket s) {
    _n = ++N;
    _socket = s;
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  void printClientLand(){
    for(int i = 0; i < 10; i++){
      for(int j = 0; j < 10; j++){
        _socket.write(_clientLand[i][j].personalString() + '-');
      }
      _socket.write('\n');
    }
  }

  void printOpponentLand(){
    for(int i = 0; i < 10; i++){
      for(int j = 0; j < 10; j++){
        _socket.write(opponent.getLand()[i][j].toString() + '-');
      }
      _socket.write('\n');
    }
  }

  String get_n(){
    return _n.toString();
  }

  List<List<dynamic>> getLand(){
    return _clientLand;
  }

  void messageHandler(data){
    String message = String.fromCharCodes(data).trim();
    if(message == 'SHOW ME'){
      printClientLand();
      return;
    }
    if(message == 'SHOW OP'){
      printOpponentLand();
      return;
    }
    if(isPlaying && isTurn){
      List<String> messages = message.split(' ');
      if(checkMessageAttack(messages)){
        if(opponent.getLand()[int.parse(messages[1])][int.parse(messages[0])].getTake()){
          opponent.hit += 1;
        }
        opponent.getLand()[int.parse(messages[1])][int.parse(messages[0])].setHit();
        _socket.write('FIRE\n');
      }
      isTurn = false;
      _socket.write('OPPONENT TURN\n');
      opponent.isTurn = true;
      opponent.write('YOUR TURN\n');
      return;
    }
    if(ready == true && isPlaying == false){
      if(ServerGame.matchMaking(_socket)){
      }else{
        _socket.write('NO MATCH, WAIT FOR OPPONENTS');
      }
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
        _socket.write('OK\n');
        if(ships.length == 0){
          ready = true;
          _socket.write('READY\n');
        }
        return;
      }
      _socket.write('NO\n');
      return;
    }
  }


  bool checkMessageAttack(List<String> message){
    if(int.parse(message[0]) < 0 ||  int.parse(message[0]) > 9 || int.parse(message[1]) < 0 || int.parse(message[1]) > 9){
      return false;
    }else{
      return true;
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
              for(int i = int.parse(message[0]); i < total; i++){
                if(_clientLand[int.parse(message[1])][i].getTake()){
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
    _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }
}
