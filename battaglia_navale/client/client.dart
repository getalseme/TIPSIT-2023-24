import 'dart:io';

void main() {
  TestualClient tc = TestualClient();
  tc.start();
}

class TestualClient{

  late Socket socket;

  bool _ready = false;
  bool _playing = false;

  void start(){
    startConnection();
  }

  void startConnection(){
    Socket.connect('192.168.62.106', 3000).then((Socket sock) {
    this.socket = sock;
    socket.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: false);
    }, onError: (e) {
      print("Unable to connect: $e");
      exit(1);
    });

    // connect standard in to the socket
    stdin.listen((data) => socket.write(String.fromCharCodes(data).trim() + '\n'));
  }

  void dataHandler(data) {
    String msgs = String.fromCharCodes(data).trim();
    List<String> msg = msgs.split('\t');
    //print(msg);
    int n = msg.length;
    for (int i = 0; i < n; i++){
      if(msg[i].contains('MAP')){
        print(msg);
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
          }
          if(msg[i] == 'TURN'){
            print("IT'S YOUR TURN");
            continue;
          }
          if(msg[i] == 'W_TURN'){
            print("WAIT YOUR TURN");
            continue;
          }
          if(msg[i] == 'HIT'){
            print("YOU HITTED ONE OF YOUR ENEMY'S SHIPS");
            continue;
          }
          if(msg[i] == 'HITTED'){
            print('ONE OF YOUR SHIPS HAS BEEN HITTED');
            continue;
          }
          if(msg[i] == 'MISS'){
            print("YOU MISSED YOUR ENEMY'S SHIPS");
            continue;
          }
          if(msg[i] == 'MISSED'){
            print('YOUR SHIPS HAS BEEN MISSED');
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
          continue;
        }
        if(msg[i] == 'NO'){
          print('COMMAND NOT ACCEPTED');
          continue;
        }
      }
    }
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    socket.destroy();
    exit(0);  
  } 
}
