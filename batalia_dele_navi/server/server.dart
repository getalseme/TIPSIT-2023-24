import 'dart:io';

// USE also netcat 127.0.0.1 3000

// global variable must be initialized later (null safety)
late Client client;

void main() {
  ServerSocket.bind(InternetAddress.anyIPv4, 3000).then((ServerSocket server) {
    print("server start");
    server.listen((socket) {
      handleConnection(socket);
    });
  });
}

void handleConnection(Socket socket) {
  client = Client(socket);
  print('client ' +
      Client.N.toString() +
      ' connected from ' +
      '${socket.remoteAddress.address}:${socket.remotePort}');
}

void messageHandler(data) {
  String message = String.fromCharCodes(data).trim();
  writeMessage(client, message);
}

void errorHandler(error) {
  print(' Error: $error');
  client.finishedHandler();
}

void finishedHandler() {
  client.finishedHandler();
}

void writeMessage(Client client, String message) {
  String str = message.toUpperCase();
  print('[' + client._n.toString() + ']: ' + str);
  client.write(str + '\n');
}

void checkMessage(Client client, String message){
  String str = message.toUpperCase();

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
  bool ready = false;
  static var _client1Land = List<List>.generate(10, (i) => List<Landpiece>.generate(10, (index) => Landpiece(), growable: false), growable: false);
  static var _client2Land = List<List>.generate(10, (i) => List<Landpiece>.generate(10, (index) => Landpiece(), growable: false), growable: false);


  Client(Socket s) {
    _n = ++N;
    _socket = s;
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  void messageHandler(data) {
    String message = String.fromCharCodes(data).trim();
    checkMessage(this, message);
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
