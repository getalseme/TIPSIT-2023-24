import 'dart:io';

late Socket socket;

void main() {
  TestualClient tc = TestualClient();
  tc.start();
}

class TestualClient{

  bool ready = false;

  String startMessage = '';

  void start(){
    startConnection();
  }

  void startConnection(){
    Socket.connect("localhost", 3000).then((Socket sock) {
    socket = sock;
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
    String msg = String.fromCharCodes(data).trim();
    if(ready){

    }else{
      if(msg == 'READY'){
        ready = true;
        return;
      }
      if(msg == 'HI'){
        print(  'WELLCOME\n' + 
                'YOU HAVE TO PLACE YOUR SHIPS\n' + 
                'THEIR DIMENTIONS ARE: 5 - 4 - 3 - 3 - 2\n' + 
                'YOU HAVE TO WRITE THE COORDINATES AND THE ORIETETION IN THIS WAY:\n' +
                '"X Y DIM ORI/VER" FOR EXEMPLLE -> "1 8 5 ORI"\n');
        return;
      }
      if(msg == 'OK'){
        print('');
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
