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
  print('[' + client._n.toString() + ']: ' + str);
  client.write(str + '\n');
}

void processMessage(Client client, String message){
  String str = message.toUpperCase();

}

class ServerGame {

  late int _port;

  List<Client> _players = [];

  ServerGame(port){
    _port = port;
  }
  
  void start(){
    ServerSocket.bind(InternetAddress.anyIPv4, _port).then((ServerSocket server) {
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
      client._n.toString() +
      ' connected from ' +
      '${socket.remoteAddress.address}:${socket.remotePort}'
    );
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

  void setTaken(){
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
  bool _ready = false;
  bool turn = false;
  static var _clientLand = List<List>.generate(10, (i) => List<Landpiece>.generate(10, (index) => Landpiece(), growable: false), growable: false);
  static var _opponentLand = List<List>.generate(10, (i) => List<Landpiece>.generate(10, (index) => Landpiece(), growable: false), growable: false);



  Client(Socket s) {
    _n = ++N;
    _socket = s;
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
    startMessage();
  }

  void printClientLand(){
    for(int i = 0; i < 10; i++){
      for(int j = 0; j < 10; j++){
        _socket.write(_clientLand[i][j]);
      }
      _socket.write('\n');
    }
  }

  void printOpponentLand(){
    for(int i = 0; i < 10; i++){
      for(int j = 0; j < 10; j++){
        _socket.write(_opponentLand[i][j]);
      }
      _socket.write('\n');
    }
  }

  void startMessage(){
    _socket.write('WELLCOME');
  }

  void messageHandler(data){
    String message = String.fromCharCodes(data).trim();
    if(_ready && turn){


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
